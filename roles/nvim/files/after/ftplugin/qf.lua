vim.keymap.set("n", "p", "<Plug>(KickfixPreview)", { silent = true, buffer = true, desc = "Preview via Kickfix" })
vim.keymap.set("n", "<C-g>", function()
  vim.cmd.QInfo()
end, { buffer = true, desc = "Number of files in quickfix list" })
