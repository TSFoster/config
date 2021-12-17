if b.did_ftplugin_user then return true end

keymap.set("i", "<C-f>", "*", { buffer=true, desc="Add *" })
keymap.set("i", "<C-d>", "**", { buffer=true, desc="Add **" })
keymap.set("v", "<C-i>", "S*", { buffer=true, desc="Surround with *" })
keymap.set("v", "<C-b>", "S*gvS*", { buffer=true, desc="Surround with **" })
keymap.set("i", ";`", "```<CR><CR>```<UP><UP>", { buffer=true, desc="Add codeblock" })

opt_local.spell = true

b.did_ftplugin_user = true
