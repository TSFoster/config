local function detect_base_ft(bufnr)
  local configured = vim.b[bufnr].jinja_base_ft
  if configured and configured ~= "" then
    return configured
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return nil
  end

  local stem = path:gsub("%.j2$", "")
  return vim.filetype.match({ filename = vim.fs.basename(stem), buf = bufnr })
    or vim.filetype.match({ filename = stem, buf = bufnr })
end

local function source_syntax(ft)
  if not ft or ft == "" or ft == "jinja" then
    return
  end

  for _, path in ipairs(vim.api.nvim_get_runtime_file("syntax/" .. ft .. ".vim", true)) do
    vim.cmd.source(vim.fn.fnameescape(path))
  end

  for _, path in ipairs(vim.api.nvim_get_runtime_file("syntax/" .. ft .. ".lua", true)) do
    if path ~= vim.api.nvim_buf_get_name(0) then
      vim.cmd.source(vim.fn.fnameescape(path))
    end
  end
end

vim.b.current_syntax = nil
source_syntax(detect_base_ft(0))

vim.cmd([[
syntax match jinjaDelimiter /{{-\=\|-\=}}\|{%-\=\|-\=%}\|{#-\=\|-\=#}/ containedin=ALL
syntax region jinjaComment start=/{#-\=/ end=/-\=#}/ keepend containedin=ALL
syntax region jinjaExpression start=/{{-\=/ end=/-\=}}/ keepend containedin=ALL
syntax region jinjaStatement start=/{%-\=/ end=/-\=%}/ keepend containedin=ALL

highlight default link jinjaDelimiter Delimiter
highlight default link jinjaComment Comment
highlight default link jinjaExpression PreProc
highlight default link jinjaStatement PreProc
]])

vim.b.current_syntax = "jinja"
