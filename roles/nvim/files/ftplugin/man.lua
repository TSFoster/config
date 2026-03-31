if vim.b.did_ftplugin_user then
  return true
end

require("config.pager").setup()

vim.b.did_ftplugin_user = true
