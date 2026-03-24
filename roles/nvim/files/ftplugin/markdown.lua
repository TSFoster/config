if vim.b.did_ftplugin_user then
  return true
end

vim.keymap.set("i", "<C-f>", "*", { buffer = true, desc = "Add *" })
vim.keymap.set("i", "<C-d>", "**", { buffer = true, desc = "Add **" })
vim.keymap.set("v", "<C-i>", "sa*", { buffer = true, remap = true, desc = "Surround with *" })
vim.keymap.set("v", "<C-b>", "sa*", { buffer = true, remap = true, desc = "Surround with **" })
vim.keymap.set("i", ";`", "```<CR><CR>```<Up><Up>", { buffer = true, desc = "Add codeblock" })

vim.opt_local.spell = true

vim.b.did_ftplugin_user = true
