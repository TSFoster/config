-- Manages terminal tools (Yazi, Claude Code, shells, etc.) and paged output,
-- each pinned to its own persistent buffer so re-focusing a tool resumes its
-- running process instead of starting a new one.
local M = {}

local tool_buffers = {}
local pager_list = {}
local pager_set = {}

-- `:restart`/`ZR` (see :h :restart, :h ZR) saves and restores a session
-- across the process restart, terminal buffers included: each one is
-- reopened by re-running its command, named `term://{cwd}//{pid}:{cmd}`,
-- and (per :h terminal-start) that exact name -- old pid and all -- survives
-- the round-trip even for buffers that were only hidden, not shown in a
-- window, at save time; those just stay unloaded until next focused, which
-- lazily reruns their command (the same mechanism `:edit term://...` uses
-- to start one). So tool_buffers, which is plain Lua state and doesn't
-- itself survive the restart, can be rebuilt after one by matching buffer
-- names back up -- *if* we squirrel away what each tool's buffer was named
-- before the restart. `:mksession` can carry that for us via
-- 'sessionoptions'+=globals, but only for String/Number globals (Lists
-- and Dicts aren't saved), hence the JSON encoding here.
local SESSION_BUFFERS_VAR = "NvimToolBuffers"

local function save_session_state()
  local names = {}
  for tool_name, buf in pairs(tool_buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      names[tool_name] = vim.api.nvim_buf_get_name(buf)
    end
  end
  vim.g[SESSION_BUFFERS_VAR] = vim.json.encode(names)
end

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
    -- bufadd() covers the rest.
    local buf = vim.fn.bufadd(buf_name)
    if buf > 0 then
      vim.bo[buf].buflisted = false
      tool_buffers[tool_name] = buf
    end
  end
end

vim.api.nvim_create_autocmd("SessionLoadPost", { callback = restore_session_state })

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

-- Focus the given tool, launching `cmd` in a terminal buffer if needed.
-- If already loaded in a window, switches to that window; otherwise loads in current window.
function M.focus(tool_name, cmd)
  local buf = tool_buffers[tool_name]
  local buf_exists = buf and vim.api.nvim_buf_is_valid(buf)
  local cwd = vim.fn.getcwd()

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
    show_buffer(buf)
  end

  save_session_state()
  vim.cmd.startinsert()
end

-- Return to the most recently used non-tool buffer.
function M.unfocus()
  if not is_tool_buf(vim.api.nvim_get_current_buf()) then
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

-- Close a pager buffer, dropping it from the cycle.
function M.close_pager(bufnr)
  for i, buf in ipairs(pager_list) do
    if buf == bufnr then
      table.remove(pager_list, i)
      break
    end
  end
  pager_set[bufnr] = nil

  if vim.api.nvim_buf_is_valid(bufnr) then
    if vim.api.nvim_get_current_buf() == bufnr then
      M.unfocus()
    end
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

return M
