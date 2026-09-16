-- Manages terminal tools (Yazi, Claude Code, shells, etc.) and paged output,
-- each pinned to its own persistent buffer so re-focusing a tool resumes its
-- running process instead of starting a new one.
local M = {}
local window_placement = require("config.window_placement")

local tool_buffers = {}
-- Which tools were last placed in a floating window (see note_float below,
-- and the M.focus/M.focus_with_placement/M.unfocus float handling). Actual
-- hide-on-blur behavior for floats lives in window_placement.open_float --
-- this table is only bookkeeping so a later M.focus resume knows to reopen
-- the tool as a float rather than in the current window.
local tool_float = {}
local pager_list = {}
local pager_set = {}

-- `:restart`/`ZR` (see :h :restart, :h ZR) carries nothing about tools
-- across the process restart: 'sessionoptions' here deliberately excludes
-- "terminal" (see config/options.lua), and it doesn't include "globals"
-- either -- that's never been added, and it isn't Neovim's default -- so
-- there's no way to smuggle `tool_buffers` itself across via a saved global.
-- A restart just forgets every tool outright: tool_buffers comes back empty,
-- and each one gets a genuinely fresh buffer/job (new pid) the next time
-- M.focus is called for it, same as if it had never been opened.
--
-- Excluding "terminal" from 'sessionoptions' still matters even though
-- nothing is being restored: without it, Neovim's own session-restore would
-- try to auto-respawn each terminal buffer itself from its saved name
-- (`term://{cwd}//{pid}:{cmd}`, per :h terminal-start) -- and since that name
-- only encodes a list-form command's argv[1], a tool started with args (e.g.
-- the `direnv exec <cwd> claude` this module launches non-shell tools with)
-- would come back running plain `direnv` with no arguments at all. Better to
-- skip that and let M.focus relaunch it properly instead.

local function is_tool_buf(bufnr)
  if pager_set[bufnr] then
    return true
  end
  for _, buf in pairs(tool_buffers) do
    if buf == bufnr then
      return true
    end
  end
  return false
end

M.is_tool_buf = is_tool_buf

local function is_shell_slot_name(name)
  return name:match("^shell_%d+$") ~= nil
end

-- If `buf` is already loaded in a window, switch to that window (preferring
-- the current tab), otherwise load it in the current window.
local function show_buffer(buf)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == buf then
      vim.api.nvim_set_current_win(win)
      return
    end
  end

  local wins = vim.fn.win_findbuf(buf)
  if #wins > 0 then
    vim.api.nvim_set_current_win(wins[1])
    return
  end

  vim.api.nvim_set_current_buf(buf)
end

-- Find the most recently used buffer that is a non-tool buffer.
local function get_mru_non_tool_buf()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(bufs, function(a, b)
    return a.lastused > b.lastused
  end)

  local current_buf = vim.api.nvim_get_current_buf()
  for _, info in ipairs(bufs) do
    local bufnr = info.bufnr
    if bufnr ~= current_buf and not is_tool_buf(bufnr) then
      return bufnr
    end
  end

  for _, info in ipairs(vim.fn.getbufinfo()) do
    local bufnr = info.bufnr
    if bufnr ~= current_buf and not is_tool_buf(bufnr) and vim.bo[bufnr].buftype == "" then
      return bufnr
    end
  end

  return nil
end

-- Whether `buf` is a loaded terminal buffer with a still-running job. A
-- buffer left behind by a tool process that already exited is still
-- `nvim_buf_is_valid` -- Neovim never invalidates a bufnr just because it's
-- unloaded or its job died -- so that check alone can't tell a genuinely
-- resumable tool from a dead one.
-- Trusting it as "already open" would silently reuse a stale/ghost buffer
-- instead of prompting to relaunch: for a list-argv tool (e.g. the
-- `direnv exec <cwd> claude` this module launches non-shell tools with),
-- reviving an unloaded term:// buffer by name also loses every arg but the
-- first, since Neovim only encodes argv[1] in a list-form terminal's buffer
-- name -- so a lazily-respawned one runs `direnv` with no arguments at all.
local function is_live_tool_buf(buf)
  if not (buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal") then
    return false
  end

  local ok, chan = pcall(function()
    return vim.bo[buf].channel
  end)
  return ok and chan and chan > 0 and vim.fn.jobwait({ chan }, 0)[1] == -1
end

-- If `buf` belongs to a named tool, remember it as floating so a later
-- M.focus resume reopens a float, same as tool_float set in
-- M.focus_with_placement. Hide-on-blur itself is already wired up by
-- window_placement.open_float() for whatever window `buf` was just placed
-- into -- this is purely tool bookkeeping, not float behavior.
local function note_float(buf)
  for name, tool_buf in pairs(tool_buffers) do
    if tool_buf == buf then
      tool_float[name] = true
      return
    end
  end
end

M.note_float = note_float

-- If `buf` belongs to a named tool, forget that it was floating -- the
-- inverse of note_float above -- so a later M.focus resume shows it in
-- place (e.g. a tab it was just popped out into) rather than reopening a
-- float.
local function note_unfloat(buf)
  for name, tool_buf in pairs(tool_buffers) do
    if tool_buf == buf then
      tool_float[name] = nil
      return
    end
  end
end

M.note_unfloat = note_unfloat

-- Focus the given tool, launching `cmd` in a terminal buffer if needed. `cmd`
-- is a single executable name/path, or a list of it plus its args -- never a
-- shell string, since jobstart() runs a list argv directly with no shell to
-- split it on spaces.
-- If already loaded in a window, switches to that window; otherwise loads in current window.
function M.focus(tool_name, cmd)
  local buf = tool_buffers[tool_name]
  local buf_exists = is_live_tool_buf(buf)
  local cwd = vim.fn.getcwd()

  if not buf_exists then
    if buf and vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
    vim.cmd.enew()
    buf = vim.api.nvim_get_current_buf()
    tool_buffers[tool_name] = buf

    -- jobstart() runs the list directly rather than through a shell. Stash
    -- the cwd explicitly so titlebar_naming has a stable fallback instead of the
    -- tool's own title (which e.g. claude rewrites continuously).
    vim.b[buf].shell_cwd = cwd
    local cmd_list = type(cmd) == "table" and cmd or { cmd }
    -- Shells already do their own direnv hooking on startup; wrapping them
    -- in `direnv exec` too is redundant, and fights an interactive shell's
    -- own env/prompt handling.
    if not is_shell_slot_name(tool_name) then
      cmd_list = vim.list_extend({ "direnv", "exec", cwd }, cmd_list)
    end
    vim.fn.jobstart(cmd_list, { cwd = cwd, term = true })
    -- If this was placed via window_placement.apply's "f" case, that
    -- already made the float current and wired up its auto-hide-on-blur --
    -- nothing more to do here.
  elseif tool_float[tool_name] and #vim.fn.win_findbuf(buf) == 0 then
    -- Floating tools are hidden outright (window closed, not just
    -- unfocused) on blur/<M-u>, so resuming one that isn't showing in any
    -- window means reopening a fresh float in "the same configuration"
    -- rather than dumping it into the current window. open_float() wires up
    -- its own auto-hide-on-blur.
    local win = window_placement.open_float()
    vim.api.nvim_win_set_buf(win, buf)
  else
    show_buffer(buf)
  end
end

-- Return to the most recently used non-tool buffer -- or, if the current
-- window is a floating tool (e.g. its blur-triggered autohide didn't fire,
-- such as a <M-u> press without ever leaving the window), hide that float
-- instead of repurposing it with a non-tool buffer.
function M.unfocus()
  local buf = vim.api.nvim_get_current_buf()
  if not is_tool_buf(buf) then
    return
  end

  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    pcall(vim.api.nvim_win_hide, win)
    return
  end

  local target_buf = get_mru_non_tool_buf()
  if target_buf then
    show_buffer(target_buf)
  else
    vim.cmd.enew()
  end
  vim.cmd.stopinsert()
end

-- Register a freshly-populated pager buffer.
function M.add_pager(bufnr)
  table.insert(pager_list, bufnr)
  pager_set[bufnr] = true
end

-- Jump to the most recently opened paged output, if any.
function M.pager_latest()
  if #pager_list == 0 then
    return
  end

  show_buffer(pager_list[#pager_list])
end

-- Cycle through live paged output by `delta` (1 = next, -1 = previous).
function M.pager_cycle(delta)
  local n = #pager_list
  if n == 0 then
    return
  end

  local current = vim.api.nvim_get_current_buf()
  local idx = nil
  for i, buf in ipairs(pager_list) do
    if buf == current then
      idx = i
      break
    end
  end
  idx = idx or (delta > 0 and 0 or (n + 1))

  local new_idx = ((idx - 1 + delta) % n) + 1
  show_buffer(pager_list[new_idx])
end

-- Jump straight to the Nth paged output, if it exists.
function M.pager_goto(n)
  local buf = pager_list[n]
  if buf and vim.api.nvim_buf_is_valid(buf) then
    show_buffer(buf)
  end
end

local SHELL_SLOT_COUNT = 9

local function shell_slot_name(n)
  return "shell_" .. n
end

-- Adopt orphaned terminal buffers (e.g. opened directly via :terminal) into
-- any empty shell_N slots, lowest buffer number first.
local function reconcile_shells()
  local used = {}
  for i = 1, SHELL_SLOT_COUNT do
    local buf = tool_buffers[shell_slot_name(i)]
    if buf and vim.api.nvim_buf_is_valid(buf) then
      used[i] = true
    end
  end

  local orphans = {}
  for _, info in ipairs(vim.fn.getbufinfo()) do
    if vim.bo[info.bufnr].buftype == "terminal" and not is_tool_buf(info.bufnr) then
      table.insert(orphans, info.bufnr)
    end
  end
  table.sort(orphans)

  local oi = 1
  for i = 1, SHELL_SLOT_COUNT do
    if not used[i] and orphans[oi] then
      tool_buffers[shell_slot_name(i)] = orphans[oi]
      oi = oi + 1
    end
  end
end

-- Every shell terminal buffer: the numbered shell_N slots first (in order --
-- these are the ones <M-1>..<M-9> can address directly), then any other
-- terminal buffer not claimed by another tool. SHELL_SLOT_COUNT caps how
-- many are individually addressable by number, not how many can exist --
-- <M-{>/<M-}> cycle through all of them.
local function get_all_shell_bufs()
  local reserved = {}
  for name, buf in pairs(tool_buffers) do
    if not is_shell_slot_name(name) then
      reserved[buf] = true
    end
  end

  local numbered = {}
  local claimed = {}
  for i = 1, SHELL_SLOT_COUNT do
    local buf = tool_buffers[shell_slot_name(i)]
    if buf and vim.api.nvim_buf_is_valid(buf) then
      table.insert(numbered, buf)
      claimed[buf] = true
    end
  end

  local extra = {}
  for _, info in ipairs(vim.fn.getbufinfo()) do
    local buf = info.bufnr
    if vim.bo[buf].buftype == "terminal" and not reserved[buf] and not claimed[buf] then
      table.insert(extra, buf)
    end
  end
  table.sort(extra)

  local all = {}
  vim.list_extend(all, numbered)
  vim.list_extend(all, extra)
  return all
end

-- Like `M.focus`, but if the tool doesn't have a buffer yet, asks where to
-- open it (left/below/above/right of the current window, the current
-- window, a new tab, or in the background) before launching it there.
function M.focus_with_placement(tool_name, cmd)
  local buf = tool_buffers[tool_name]
  if is_live_tool_buf(buf) then
    M.focus(tool_name, cmd)
    return
  end

  window_placement.prompt(function(char)
    -- Remembered so a later M.focus() resume (re-pressing the same keymap
    -- after the float hides itself, or after M.unfocus hides it) knows to
    -- reopen a float instead of showing the tool in the current window.
    tool_float[tool_name] = char == "f"

    if char == "z" then
      M.focus_background(tool_name, cmd)
    else
      window_placement.apply(char, function()
        M.focus(tool_name, cmd)
      end)
    end
  end, { "z    background" })
end

-- Like `M.focus`, but creates the tool's buffer/job without displaying it or
-- moving focus. jobstart(term=true) only works on the *current* buffer, so
-- the target buffer is made current just long enough to start the job, then
-- the original window/buffer are restored. Uses nvim_create_buf() rather
-- than `:enew` -- if the current window happened to hold a pristine
-- (unnamed, unmodified) buffer, `:enew` would recycle it instead of making a
-- new one, so "restoring" it afterwards would just leave the terminal on
-- screen instead of hiding it.
function M.focus_background(tool_name, cmd)
  local win = vim.api.nvim_get_current_win()
  local orig_buf = vim.api.nvim_win_get_buf(win)
  local cwd = vim.fn.getcwd()

  local stale_buf = tool_buffers[tool_name]
  if stale_buf and vim.api.nvim_buf_is_valid(stale_buf) then
    pcall(vim.api.nvim_buf_delete, stale_buf, { force = true })
  end

  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_win_set_buf(win, buf)
  tool_buffers[tool_name] = buf
  vim.b[buf].shell_cwd = cwd

  local cmd_list = type(cmd) == "table" and cmd or { cmd }
  if not is_shell_slot_name(tool_name) then
    cmd_list = vim.list_extend({ "direnv", "exec", cwd }, cmd_list)
  end
  vim.fn.jobstart(cmd_list, { cwd = cwd, term = true })

  vim.api.nvim_win_set_buf(win, orig_buf)
  vim.cmd.stopinsert()
end

-- Focus the most recently used shell terminal buffer (any of them, not just
-- the numbered slots), or (with placement) create shell_1 if none exist yet.
function M.focus_mru_shell(cmd)
  reconcile_shells()
  local bufs = get_all_shell_bufs()
  if #bufs == 0 then
    M.focus_with_placement(shell_slot_name(1), cmd)
    return
  end

  local lastused = {}
  for _, info in ipairs(vim.fn.getbufinfo()) do
    lastused[info.bufnr] = info.lastused
  end
  table.sort(bufs, function(a, b)
    return (lastused[a] or 0) > (lastused[b] or 0)
  end)

  show_buffer(bufs[1])
end

-- Focus shell slot N (with placement, if it doesn't exist yet), first
-- adopting any orphaned terminal buffers into empty slots.
function M.focus_shell(n, cmd)
  reconcile_shells()
  M.focus_with_placement(shell_slot_name(n), cmd)
end

-- Find the lowest-numbered empty shell slot (1..SHELL_SLOT_COUNT), first
-- adopting any orphaned terminal buffers into empty slots. Falls back to the
-- next slot past SHELL_SLOT_COUNT if all numbered slots are taken -- it just
-- won't be individually addressable via <M-1>..<M-9>.
local function first_free_shell_slot()
  reconcile_shells()
  for i = 1, SHELL_SLOT_COUNT do
    local buf = tool_buffers[shell_slot_name(i)]
    if not (buf and vim.api.nvim_buf_is_valid(buf)) then
      return i
    end
  end
  return SHELL_SLOT_COUNT + 1
end

-- Open a new shell tool in the first available slot, prompting for placement.
function M.new_shell(cmd)
  M.focus_with_placement(shell_slot_name(first_free_shell_slot()), cmd)
end

-- Cycle through every shell terminal buffer (numbered slots in order, then
-- any others) by `delta` (1 = next, -1 = previous).
function M.cycle_shell(delta, cmd)
  reconcile_shells()
  local bufs = get_all_shell_bufs()
  if #bufs == 0 then
    M.focus_with_placement(shell_slot_name(1), cmd)
    return
  end

  local current = vim.api.nvim_get_current_buf()
  local idx = nil
  for i, buf in ipairs(bufs) do
    if buf == current then
      idx = i
      break
    end
  end
  idx = idx or (delta > 0 and 0 or (#bufs + 1))

  local new_idx = ((idx - 1 + delta) % #bufs) + 1
  show_buffer(bufs[new_idx])
end

return M
