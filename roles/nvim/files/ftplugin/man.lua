if vim.b.did_ftplugin_user then
  return true
end

vim.fn["buffer#init_pager"]()

vim.b.did_ftplugin_user = true
