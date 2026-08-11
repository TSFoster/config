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

function M.selection_info()
  local cur_win = vim.api.nvim_get_current_win()
  local prev_win = vim.fn.win_getid(vim.fn.winnr("#"))
  local target_win = (prev_win > 0 and prev_win ~= cur_win) and prev_win or 0

  if target_win == 0 then
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if w ~= cur_win then
        local b = vim.api.nvim_win_get_buf(w)
        if vim.bo[b].buftype ~= "terminal" then
          target_win = w
          break
        end
      end
    end
  end
  if target_win == 0 then target_win = cur_win end

  local b = vim.api.nvim_win_get_buf(target_win)
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
    local cursor = vim.api.nvim_win_get_cursor(target_win)
    start_line = cursor[1]
    end_line = cursor[1]
    local l = vim.api.nvim_buf_get_lines(b, cursor[1] - 1, cursor[1], false)
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

function M.copy_pandoc(text, format, reg)
  local args = { "pandoc", "-f", "markdown", "-t", format }
  if format == "rtf" then
    table.insert(args, "-s")
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
