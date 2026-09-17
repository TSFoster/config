-- Shared "where should this go?" window-placement prompt: a small floating
-- legend in the middle of the screen that reads one keystroke (h/j/k/l/w/t/f)
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
  "f    floating window",
}

local FLOAT_SCALE = 0.95

-- Auto-hide a floating window -- closing the window, not whatever buffer/job
-- is behind it -- the moment focus leaves it, so switching to another window
-- dismisses it without needing an explicit unfocus command. Checks that
-- `win` itself is the one being left (WinLeave fires on every window leave,
-- not just this one) and, once it has, deletes its own augroup rather than
-- using `once = true`, since a leave of some other window shouldn't
-- consume/disarm this one. Every window M.open_float() creates gets this
-- wired up automatically, so any caller's floated buffer hides on blur, not
-- just tool buffers.
function M.autohide(win)
  local group = vim.api.nvim_create_augroup("FloatAutohide" .. win, { clear = true })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    callback = function()
      if vim.api.nvim_get_current_win() == win then
        pcall(vim.api.nvim_win_hide, win)
        pcall(vim.api.nvim_del_augroup_by_id, group)
      end
    end,
  })
end

-- Open a centered floating scratch window sized to FLOAT_SCALE of the
-- editor, make it current, wire up auto-hide-on-blur, and return its window
-- id. The scratch buffer is disposable -- callers (e.g. M.apply's "f" case,
-- or tools.lua reopening a previously-hidden floating tool) immediately
-- replace it with their own buffer, same as e.g. the "t" case replaces
-- tabnew()'s initial buffer.
function M.open_float()
  local width = math.floor(vim.o.columns * FLOAT_SCALE)
  local height = math.floor(vim.o.lines * FLOAT_SCALE)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })
  M.autohide(win)
  return win
end

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

-- Places `char` (h/j/k/l/w/t/f, or space/enter as an alias for "w") and calls
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
  elseif char == "f" then
    M.open_float()
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
