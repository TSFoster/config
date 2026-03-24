if vim.b.did_ftplugin_user then
  return true
end

vim.opt_local.spell = true
vim.opt_local.bufhidden = "delete"

vim.b.did_ftplugin_user = true
