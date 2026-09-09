-- Manages a dedicated tab that hosts terminal tools (Yazi, Claude Code, shells,
-- etc.), each pinned to its own persistent buffer so re-focusing a tool resumes
-- its running process instead of starting a new one. Paged output ($PAGER)
-- lives in this same tab: it doesn't get a persistent slot of its own, but
-- shares whatever window is current, remembering what it displaced so `q` can
-- put it back.
local M = {}

local tools_tab_id = nil
local tool_buffers = {}
local previous_tab_id = nil

-- `:restart`/`ZR` (see :h :restart, :h ZR) saves and restores a session
-- across the process restart, terminal buffers included: each one is
-- reopened by re-running its command, named `term://{cwd}//{pid}:{cmd}`,
-- and (per :h terminal-start) that exact name -- old pid and all -- survives
-- the round-trip even for buffers that were only hidden, not shown in a
-- window, at save time; those just stay unloaded until next focused, which
-- lazily reruns their command (the same mechanism `:edit term://...` uses
-- to start one). So tool_buffers/tools_tab_id, which are plain Lua
-- state and don't themselves survive the restart, can be rebuilt after one
-- by matching buffer names back up -- *if* we squirrel away what each tool's
-- buffer was named before the restart. `:mksession` can carry that for us
-- via 'sessionoptions'+=globals, but only for String/Number globals (Lists
-- and Dicts aren't saved), hence the JSON encoding here rather than a plain
-- table.
local SESSION_BUFFERS_VAR = "NvimToolBuffers"
local SESSION_TAB_VAR = "NvimToolsTab"

-- Snapshot tool_buffers/tools_tab_id into session-savable globals. Called
-- whenever either changes, so a `:restart` mid-session always saves a
-- current picture rather than needing its own save hook.
local function save_session_state()
  local names = {}
  for tool_name, buf in pairs(tool_buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      names[tool_name] = vim.api.nvim_buf_get_name(buf)
    end
  end
  vim.g[SESSION_BUFFERS_VAR] = vim.json.encode(names)

  if tools_tab_id and vim.api.nvim_tabpage_is_valid(tools_tab_id) then
    vim.g[SESSION_TAB_VAR] = vim.api.nvim_tabpage_get_number(tools_tab_id)
  else
    vim.g[SESSION_TAB_VAR] = nil
  end
end

-- Reconstruct tool_buffers/tools_tab_id after a session restore, matching
-- the tool-name -> buffer-name snapshot from before the restart against the
-- buffers that actually came back. Registered on SessionLoadPost, which
-- fires for `:restart`'s own restore as well as a manual :mksession/:source
-- (e.g. via mini.sessions).
local function restore_session_state()
  local raw = vim.g[SESSION_BUFFERS_VAR]
  if not raw then
    return
  end

  local ok, names = pcall(vim.json.decode, raw)
  if not ok or type(names) ~= "table" then
    return
  end

  for tool_name, buf_name in pairs(names) do
    -- mksession only restores a hidden buffer if it's buflisted, and tool
    -- buffers deliberately aren't (to stay out of :ls) -- so at most the one
    -- tool that was on-screen at save time comes back this way on its own.
    -- bufadd() covers the rest: for a name mksession did already restore it
    -- just returns that buffer, and for one it dropped it (re-)creates the
    -- still-unloaded buffer under the exact name it had before, which Nvim's
    -- term:// handling reruns {cmd} for lazily, the first time something
    -- actually switches to it -- same as a freshly badd'ed one would.
    local buf = vim.fn.bufadd(buf_name)
    if buf > 0 then
      vim.bo[buf].buflisted = false
      tool_buffers[tool_name] = buf
    end
  end

  local tab_number = vim.g[SESSION_TAB_VAR]
  local tab = tab_number and vim.api.nvim_list_tabpages()[tab_number]
  if tab and vim.api.nvim_tabpage_is_valid(tab) then
    tools_tab_id = tab
  end
end

vim.api.nvim_create_autocmd("SessionLoadPost", { callback = restore_session_state })

-- Ordered oldest->newest list of live pager buffers, plus a lookup set of the
-- same, and a per-window memory of the buffer a pager display replaced (so
-- closing a pager can restore it) keyed by window id.
local pager_list = {}
local pager_set = {}
local pager_prev_buf = {}

-- Find or create the tools tab and make it current, without touching
-- previous_tab_id (callers decide what "where we came from" means).
local function ensure_tools_tab()
  if tools_tab_id and vim.api.nvim_tabpage_is_valid(tools_tab_id) then
    if vim.api.nvim_get_current_tabpage() ~= tools_tab_id then
      vim.api.nvim_set_current_tabpage(tools_tab_id)
    end
  else
    vim.cmd.tabnew()
    vim.cmd.tabmove(0)
    tools_tab_id = vim.api.nvim_get_current_tabpage()
  end
end

-- Find or create the tools tab and make it current, remembering the tab we
-- were actually on so M.unfocus can return there.
local function goto_tools_tab()
  local current_tab = vim.api.nvim_get_current_tabpage()
  if current_tab ~= tools_tab_id then
    previous_tab_id = current_tab
  end
  ensure_tools_tab()
end

-- Show `buf` in the current tab: reuse a window already showing it, otherwise
-- take over the current window. If `on_replace` is given and a window's
-- buffer is about to be replaced (the "otherwise" case), it's called with
-- (win, previous_buf) before the swap.
local function focus_buf_in_tab(buf, on_replace)
  local win_with_buf = nil
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == buf then
      win_with_buf = win
      break
    end
  end

  if win_with_buf then
    vim.api.nvim_set_current_win(win_with_buf)
  else
    local win = vim.api.nvim_get_current_win()
    if on_replace then
      on_replace(win, vim.api.nvim_win_get_buf(win))
    end
    vim.api.nvim_set_current_buf(buf)
  end
end

-- Show a pager buffer, remembering what it displaced (unless what it
-- displaced was itself a pager, so a chain of cycling doesn't lose the
-- original buffer to restore to). Explicitly leaves insert/terminal mode:
-- the window we're taking over may have been showing a terminal tool with
-- insert mode active, and switching its buffer doesn't clear that on its own.
local function place_pager(buf)
  focus_buf_in_tab(buf, function(win, prev_buf)
    if not pager_set[prev_buf] then
      pager_prev_buf[win] = prev_buf
    end
  end)
  vim.cmd.stopinsert()
end

-- Focus the given tool, creating the tools tab and/or launching `cmd` in a
-- terminal buffer if needed. Always leaves you focused on the tool; use
-- M.unfocus to return to where you were before.
function M.focus(tool_name, cmd)
  local buf = tool_buffers[tool_name]
  local buf_exists = buf and vim.api.nvim_buf_is_valid(buf)
  local cwd = vim.fn.getcwd()

  goto_tools_tab()

  if not buf_exists then
    vim.cmd.enew()
    buf = vim.api.nvim_get_current_buf()
    tool_buffers[tool_name] = buf

    -- Hide the buffer from :ls
    vim.api.nvim_set_option_value("buflisted", false, { buf = buf })

    -- termopen() runs `cmd` directly rather than through a shell. Stash
    -- the cwd explicitly so titlebar_naming has a stable fallback instead of the
    -- tool's own title (which e.g. claude rewrites continuously).
    vim.b[buf].shell_cwd = cwd
    vim.fn.termopen(cmd, { cwd = cwd })
  else
    focus_buf_in_tab(buf)
  end

  save_session_state()
  vim.cmd.startinsert()
end

-- Register a freshly-populated pager buffer and display it, taking over the
-- tools tab's current window. `source_tab`, if given, is recorded as where
-- M.unfocus should return to; pass this explicitly when the buffer arrived
-- via a throwaway tab (e.g. nvr's --remote-tab-wait) so "current tab" isn't
-- mistaken for where the user actually was.
function M.add_pager(bufnr, source_tab)
  if source_tab and vim.api.nvim_tabpage_is_valid(source_tab) and source_tab ~= tools_tab_id then
    previous_tab_id = source_tab
    ensure_tools_tab()
  else
    goto_tools_tab()
  end
  table.insert(pager_list, bufnr)
  pager_set[bufnr] = true
  place_pager(bufnr)
end

-- Jump to the most recently opened paged output, if any.
function M.pager_latest()
  if #pager_list == 0 then
    return
  end

  goto_tools_tab()
  place_pager(pager_list[#pager_list])
end

-- Cycle through all live paged output by `delta` (1 = next, -1 = previous),
-- wrapping around. Starts from the newest end if the current buffer isn't
-- itself paged output.
function M.pager_cycle(delta)
  local n = #pager_list
  if n == 0 then
    return
  end

  goto_tools_tab()

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
  place_pager(pager_list[new_idx])
end

-- Close a pager buffer, dropping it from the cycle and restoring whatever
-- buffer it had displaced in its window, if anything.
function M.close_pager(bufnr)
  for i, buf in ipairs(pager_list) do
    if buf == bufnr then
      table.remove(pager_list, i)
      break
    end
  end
  pager_set[bufnr] = nil

  local win = vim.api.nvim_get_current_win()
  local restore_buf = pager_prev_buf[win]
  pager_prev_buf[win] = nil

  vim.api.nvim_buf_delete(bufnr, { force = true })

  if restore_buf and vim.api.nvim_buf_is_valid(restore_buf) and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_buf(win, restore_buf)
  end
end

-- Leave the tools tab and return to wherever focus was before it, if we're
-- currently in it.
function M.unfocus()
  if not (tools_tab_id and vim.api.nvim_tabpage_is_valid(tools_tab_id)) then
    return
  end

  if vim.api.nvim_get_current_tabpage() ~= tools_tab_id then
    return
  end

  if previous_tab_id and vim.api.nvim_tabpage_is_valid(previous_tab_id) then
    vim.api.nvim_set_current_tabpage(previous_tab_id)
  else
    if #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd.tabprevious()
    else
      local target_buf = nil
      local bufs = vim.api.nvim_list_bufs()
      for i = #bufs, 1, -1 do
        local b = bufs[i]
        if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_get_option_value("buflisted", { buf = b }) then
          if vim.api.nvim_get_option_value("buftype", { buf = b }) == "" then
            target_buf = b
            break
          elseif not target_buf then
            target_buf = b
          end
        end
      end

      if target_buf then
        vim.cmd("tab sbuffer " .. target_buf)
      else
        vim.cmd.tabnew()
      end
    end
  end
end

-- Kill every tool's terminal buffer and close the tools tab.
function M.close_all()
  for _, buf in pairs(tool_buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  tool_buffers = {}

  for _, buf in ipairs(pager_list) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  pager_list = {}
  pager_set = {}
  pager_prev_buf = {}

  if tools_tab_id and vim.api.nvim_tabpage_is_valid(tools_tab_id) then
    vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(tools_tab_id))
  end
  tools_tab_id = nil

  save_session_state()
end

return M
