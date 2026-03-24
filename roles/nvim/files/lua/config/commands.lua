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

vim.api.nvim_create_user_command("Format", function()
  lsp.format_buffer()
end, { desc = "Format current buffer" })
