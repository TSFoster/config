-- Manages a dedicated tab that hosts terminal tools (Yazi, Claude Code, shells,
-- etc.), each pinned to its own persistent buffer so re-focusing a tool resumes
-- its running process instead of starting a new one.
local M = {}

local tools_tab_id = nil
local tool_buffers = {}
local previous_tab_id = nil

-- Focus the given tool, creating the tools tab and/or launching `cmd` in a
-- terminal buffer if needed. Always leaves you focused on the tool; use
-- M.unfocus to return to where you were before.
function M.focus(tool_name, cmd)
  local buf = tool_buffers[tool_name]
  local buf_exists = buf and vim.api.nvim_buf_is_valid(buf)
  local current_tab = vim.api.nvim_get_current_tabpage()
  local cwd = vim.fn.getcwd()

  -- 1. Find or create the tools tab
  if tools_tab_id and vim.api.nvim_tabpage_is_valid(tools_tab_id) then
    if current_tab ~= tools_tab_id then
      previous_tab_id = current_tab
      vim.api.nvim_set_current_tabpage(tools_tab_id)
    end
  else
    previous_tab_id = current_tab
    vim.cmd.tabnew()
    vim.cmd.tabmove(0)
    tools_tab_id = vim.api.nvim_get_current_tabpage()
  end

  -- 2. Open or switch to the tool buffer
  if not buf_exists then
    vim.cmd.enew()
    buf = vim.api.nvim_get_current_buf()
    tool_buffers[tool_name] = buf

    -- Hide the buffer from :ls
    vim.api.nvim_set_option_value("buflisted", false, { buf = buf })

    -- termopen() runs `cmd` directly rather than through a shell, so it never
    -- emits the OSC 7 that terminal_osc7_cwd relies on to learn the cwd. Stash
    -- it explicitly so titlebar_naming has a stable fallback instead of the
    -- tool's own title (which e.g. claude rewrites continuously).
    vim.b[buf].shell_cwd = cwd
    vim.fn.termopen(cmd, { cwd = cwd })
  else
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
      vim.api.nvim_set_current_buf(buf)
    end
  end

  vim.cmd.startinsert()
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

  if tools_tab_id and vim.api.nvim_tabpage_is_valid(tools_tab_id) then
    vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(tools_tab_id))
  end
  tools_tab_id = nil
end

return M
