if b.did_ftplugin_user then return true end

keymap.set(
  "n", "yo/",
  function() o.conceallevel = (o.conceallevel == 0 and 2 or 0) end,
  { buffer = true, desc = "Cycle conceallevel" }
)
keymap.set("n", "g.", ":e %", { buffer = true, desc = "New file mapping" })
keymap.set("n", "<Leader>.", ":! mkdir %", { buffer = true, desc = "New folder mapping" })

b.did_ftplugin_user = true
