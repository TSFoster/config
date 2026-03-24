local M = {}

function M.mk_fn(fn, arg)
  return function()
    return fn(arg)
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

return M
