if vim.b.did_ftplugin_user then
  return true
end

vim.opt_local.backup = false
vim.opt_local.writebackup = false

vim.b.did_ftplugin_user = true
