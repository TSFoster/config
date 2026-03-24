if vim.b.did_ftplugin_user then
  return true
end

vim.b.switch_custom_definitions = { { "pick", "reword", "edit", "squash", "fixup", "exec" } }

vim.b.did_ftplugin_user = true
