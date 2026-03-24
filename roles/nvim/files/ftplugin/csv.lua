if vim.b.did_ftplugin_user then
  return true
end

vim.cmd.packadd("csv.vim")

vim.b.did_ftplugin_user = true
