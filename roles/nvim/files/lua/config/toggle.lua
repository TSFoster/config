local M = {}

local function current_tab_has_quickfix()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.tabnr == vim.fn.tabpagenr() and win.quickfix == 1 and win.loclist == 0 then
      return true
    end
  end

  return false
end

function M.quickfix_list(open)
  if open == nil or open == 0 then
    if current_tab_has_quickfix() then
      vim.cmd.cclose()
      return
    end
  end

  if open == nil or open == 1 then
    vim.cmd.copen()
  end
end

function M.location_list(open)
  local window = vim.fn.getloclist(0, { winid = 0 }).winid

  if open == nil or open == 0 then
    if window ~= 0 then
      vim.cmd("silent! lclose")
      vim.cmd("silent! lclose")
      return
    end
  end

  if open == nil or open == 1 then
    local ok = pcall(vim.cmd, "silent! lopen")
    if not ok or vim.fn.getloclist(0, { winid = 0 }).winid == 0 then
      vim.api.nvim_echo({ { "No items in location list" } }, false, {})
    end
  end
end

function M.inccommand()
  if vim.o.inccommand == "nosplit" then
    vim.o.inccommand = "split"
    vim.api.nvim_echo({ { "Show split" } }, false, {})
  elseif vim.o.inccommand == "split" then
    vim.o.inccommand = ""
    vim.api.nvim_echo({ { "No previews" } }, false, {})
  else
    vim.o.inccommand = "nosplit"
    vim.api.nvim_echo({ { "Preview but no split" } }, false, {})
  end
end

function M.tabs(use_tabs)
  if (use_tabs == nil and vim.bo.expandtab) or use_tabs == 1 then
    vim.opt_local.expandtab = false
  else
    vim.opt_local.expandtab = true
  end

  local message
  if vim.bo.expandtab then
    message = string.format("Spaces (%d)", vim.bo.shiftwidth)
  else
    message = string.format("Tabs (%d)", vim.bo.tabstop)
  end

  vim.api.nvim_echo({ { message } }, false, {})
end

return M
