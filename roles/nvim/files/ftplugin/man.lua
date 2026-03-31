local buffer = require("config.buffer")

if vim.b.did_ftplugin_user then
  return true
end

buffer.init_pager()

vim.b.did_ftplugin_user = true
