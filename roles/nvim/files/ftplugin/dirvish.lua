if vim.b.did_ftplugin_user then
  return true
end

vim.keymap.set(
  "n", "yo/",
  function()
    vim.wo.conceallevel = (vim.wo.conceallevel == 0 and 2 or 0)
  end,
  { buffer = true, desc = "Cycle conceallevel" }
)
vim.keymap.set("n", "g.", ":edit %<CR>", { buffer = true, desc = "New file mapping" })
vim.keymap.set("n", "<Leader>.", ":!mkdir %<CR>", { buffer = true, desc = "New folder mapping" })

vim.b.did_ftplugin_user = true
