keymap.set("n", "p", "<Plug>(KickfixPreview)", { silent=true, buffer=true, desc="Preview via Kickfix" })
keymap.set("n", "<C-g>", function() cmd "QInfo" end, { buffer=true, desc="Number of files in quickfix list" })
