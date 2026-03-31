local buffer = require("config.buffer")
local lsp = require("config.lsp")
local util = require("config.util")

vim.api.nvim_create_user_command("Keywordprg", function(params)
  if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" }) > 0 then
    vim.lsp.buf.hover()
  elseif vim.bo.filetype == "vim" or vim.bo.filetype == "help" then
    vim.cmd("help " .. vim.fn.expand("<cword>"))
  elseif vim.bo.filetype == "fish" then
    vim.cmd("Man " .. vim.fn.system("man -w " .. vim.fn.expand("<cword>")))
  elseif vim.bo.filetype == "shell" or vim.bo.filetype == "sh" or vim.bo.filetype == "bash" or vim.bo.filetype == "zsh" then
    vim.cmd("Man " .. vim.fn.expand("<cword>"))
  elseif not vim.env.SSH_CLIENT then
    vim.fn.system("search " .. params.args)
  else
    vim.cmd([[echoerr "Don't know what keyword program to use"]])
  end
end, { nargs = "+" })
vim.o.keywordprg = ":Keywordprg"

vim.api.nvim_create_user_command("Stab", function(params)
  local tabstop = tonumber(params.fargs[1])
  if tabstop and tabstop > 0 then
    vim.opt_local.softtabstop = tabstop
    vim.opt_local.tabstop = tabstop
    vim.opt_local.shiftwidth = tabstop
  end

  if params.bang then
    util.cursor_preserve_cmd("normal gg=G")
  end
end, { nargs = 1, bang = true, desc = "Quick way to change tab stops. Add bang to reformat file" })

vim.api.nvim_create_user_command("Bd", function(params)
  local mini_bufremove = util.safe_require("mini.bufremove")
  if mini_bufremove then
    mini_bufremove.delete(0, params.bang)
    return
  end

  vim.cmd("bp | bd" .. (params.bang and "!" or "") .. " #")
end, { nargs = 0, bang = true, desc = "Delete buffer while preserving window splits" })

vim.api.nvim_create_user_command("PagerInit", function()
  buffer.init_pager()
end, { desc = "Configure current buffer for pager output" })

vim.api.nvim_create_user_command("WipeoutHidden", function(params)
  buffer.wipeout(params.bang)
end, { nargs = 0, bang = true, desc = "Delete hidden unmodified buffers" })

vim.api.nvim_create_user_command("Format", function()
  lsp.format_buffer()
end, { desc = "Format current buffer" })

local function split_command_args(args)
  if args == "" then
    return {}
  end

  local parts = vim.split(vim.trim(args), "%s+")

  if parts[1] == "" then
    return {}
  end

  return parts
end

local function grep_completion(arglead, cmdline)
  local args = cmdline:gsub("^%S+%s*", "")
  local has_trailing_space = args:match("%s$") ~= nil
  local parts = split_command_args(args)
  local completed_args = #parts

  if has_trailing_space then
    completed_args = completed_args + 1
  end

  if completed_args <= 1 then
    return {}
  end

  return vim.fn.getcompletion(arglead, "file_in_path")
end

local function create_silent_grep_command(name, target, list_name)
  vim.api.nvim_create_user_command(name, function(params)
    local parsed = vim.api.nvim_parse_cmd(target .. " " .. params.args, {})
    parsed.mods.silent = true
    parsed.mods.emsg_silent = true
    vim.api.nvim_cmd(parsed, {})
  end, {
    nargs = "+",
    complete = grep_completion,
    desc = string.format("%s with grep without echoing errors", list_name),
  })
end

create_silent_grep_command("Grep", "grep", "Populate quickfix")
create_silent_grep_command("Grepadd", "grepadd", "Add to quickfix")
create_silent_grep_command("Lgrep", "lgrep", "Populate location list")
create_silent_grep_command("Lgrepadd", "lgrepadd", "Add to location list")
