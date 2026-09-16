-- Shared "where should this go?" window-placement prompt: a small floating
-- legend in the middle of the screen that reads one keystroke (h/j/k/l/w/t)
-- and places a new window accordingly. Used by tools.lua for tool buffers,
-- and by the yazi.nvim integration for opening files -- yazi.nvim's own
-- open_and_pick_window action requires snacks.nvim, which we don't install.
local M = {}

M.split_commands = {
  h = "leftabove vsplit",
  j = "rightbelow split",
  k = "leftabove split",
  l = "rightbelow vsplit",
}

local BASE_LEGEND = {
  "Where?",
  "h    to left",
  "j    below",
  "k    above",
  "l    to right",
  "w    current window",
  "t    new tab",
}

-- Show a small floating "Where?" prompt (with a legend of the keys below,
-- plus any caller-supplied `extra_legend` lines) in the middle of the screen
-- and call `callback` with the next keystroke; cancelled (e.g. <Esc>)
-- keystrokes just don't call it at all.
function M.prompt(callback, extra_legend)
  local legend = BASE_LEGEND
  if extra_legend then
    legend = vim.list_extend(vim.deepcopy(BASE_LEGEND), extra_legend)
  end

  local width = 0
  for _, line in ipairs(legend) do
    width = math.max(width, #line)
  end
  width = width + 2

  local lines = {}
  for _, line in ipairs(legend) do
    table.insert(lines, (" %-" .. (width - 2) .. "s "):format(line))
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_add_highlight(buf, -1, "Title", 0, 0, -1)

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = width,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    focusable = false,
    noautocmd = true,
  })

  vim.cmd.redraw()
  local ok, char = pcall(vim.fn.getcharstr)
  pcall(vim.api.nvim_win_close, win, true)

  if ok then
    callback(char)
  end
end

-- Places `char` (h/j/k/l/w/t, or space/enter as an alias for "w") and calls
-- `open` in the resulting window. Returns true if `char` was recognized and
-- handled, false otherwise -- so callers can still handle their own extra
-- legend chars (e.g. tools.lua's "z" for background).
function M.apply(char, open)
  if char == "w" or char == " " or char == "\n" then
    open()
    return true
  elseif char == "t" then
    vim.cmd.tabnew()
    open()
    return true
  elseif M.split_commands[char] then
    vim.cmd(M.split_commands[char])
    open()
    return true
  end
  return false
end

return M
