local M = {}

function M.mk_fn(fn, arg)
  return function()
    local ok, result = pcall(fn, arg)
    if not ok then
      vim.notify(result, vim.log.levels.ERROR)
      return nil
    end

    return result
  end
end

function M.cursor_preserve_cmd(command)
  local search_register = vim.fn.getreg("/", 1)
  local line = vim.fn.line(".")
  local col = vim.fn.col(".")

  vim.cmd(command)
  vim.fn.setreg("/", search_register)
  vim.fn.cursor(line, col)
end

function M.safe_require(module)
  local ok, value = pcall(require, module)
  if not ok then
    return nil
  end

  return value
end

function M.current_buffer_dir()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return vim.fn.getcwd()
  end

  return vim.fn.fnamemodify(path, ":p:h")
end

function M.project_root()
  local path = vim.api.nvim_buf_get_name(0)
  return vim.fs.root(path ~= "" and path or vim.fn.getcwd(), { ".git", ".hg", "package.json", "go.mod", "Cargo.toml", "pyproject.toml", "elm.json" })
    or vim.fn.getcwd()
end

function M.has_executable(command)
  return vim.fn.executable(command) == 1
end

local last_selection_buf = nil

local function is_selectable(buf)
  return buf ~= nil and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype ~= "terminal"
end

-- Called from an autocmd (see autocmds.lua) whenever visual mode is left, so
-- selection_info() can find the last-made selection even after you've
-- deselected and switched to another window/tab (e.g. a terminal buffer
-- running an agent).
function M.track_selection(buf)
  if is_selectable(buf) then
    last_selection_buf = buf
  end
end

function M.selection_info()
  local b = vim.api.nvim_get_current_buf()

  -- Called from a terminal (e.g. an agent): report the last real selection
  -- instead, if one has been tracked this session.
  if vim.bo[b].buftype == "terminal" and is_selectable(last_selection_buf) then
    b = last_selection_buf
  end

  local name = vim.api.nvim_buf_get_name(b)
  local file = name ~= "" and vim.fn.fnamemodify(name, ":.") or "[No Name]"

  local ms = vim.api.nvim_buf_get_mark(b, "<")
  local me = vim.api.nvim_buf_get_mark(b, ">")

  local text = ""
  local start_line = ms[1]
  local end_line = me[1]

  if start_line > 0 and end_line > 0 then
    local l = vim.api.nvim_buf_get_lines(b, math.min(ms[1], me[1]) - 1, math.max(ms[1], me[1]), false)
    text = table.concat(l, "\n")
  else
    -- No selection recorded in this buffer; use its last cursor position
    -- instead (buffer-local, so this works even if the buffer isn't
    -- currently displayed in any window).
    local cursor_mark = vim.api.nvim_buf_get_mark(b, ".")
    start_line = cursor_mark[1] > 0 and cursor_mark[1] or 1
    end_line = start_line
    local l = vim.api.nvim_buf_get_lines(b, start_line - 1, start_line, false)
    text = l[1] or ""
  end

  return {
    file = file,
    abs_path = name,
    buftype = vim.bo[b].buftype,
    filetype = vim.bo[b].filetype,
    start_line = start_line,
    end_line = end_line,
    text = text,
  }
end

function M.selection_json()
  return vim.fn.json_encode(M.selection_info())
end

function M.selection_ref()
  local info = M.selection_info()
  if info.start_line > 0 and info.end_line > 0 and info.start_line ~= info.end_line then
    return string.format("%s#L%d-L%d", info.file, info.start_line, info.end_line)
  else
    return string.format("%s#L%d", info.file, info.start_line)
  end
end

function M.copy_pandoc(text, format, reg, font_size)
  local args = { "pandoc", "-f", "markdown", "-t", format }
  if format == "rtf" then
    table.insert(args, "-s")
    if font_size then
      vim.list_extend(args, { "-V", "fontsize=" .. font_size })
    end
  end
  local result = vim.fn.system(args, text)
  if vim.v.shell_error == 0 then
    local target_reg = (reg == "" or reg == nil) and "*" or reg
    vim.fn.setreg(target_reg, result)
    vim.notify("Copied " .. format:upper() .. " to register " .. target_reg)
  else
    vim.notify("Pandoc error: " .. result, vim.log.levels.ERROR)
  end
end

return M
