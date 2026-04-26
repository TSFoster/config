if vim.b.did_ftplugin_user then
  return true
end

vim.b.did_ftplugin_user = true

vim.opt_local.commentstring = "{# %s #}"
vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "|setlocal commentstring<"
