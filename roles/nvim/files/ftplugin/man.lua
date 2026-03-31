if vim.b.did_ftplugin_user then
  return true
end

require("config.buffer").init_pager()

vim.b.did_ftplugin_user = true
