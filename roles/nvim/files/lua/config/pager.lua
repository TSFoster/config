-- lua/pager.lua
local M = {}

local ns = vim.api.nvim_create_namespace("pager_overstrike")

local function decode_overstrike_line(line)
  local out = {}
  local spans = {}
  local i = 1
  local col = 0

  while i <= #line do
    local a = line:sub(i, i)
    local b = line:sub(i + 1, i + 1)
    local c = line:sub(i + 2, i + 2)

    -- underline: _ <BS> x
    if b == "\b" and a == "_" and c ~= "" then
      out[#out + 1] = c
      spans[#spans + 1] = { col, col + 1, "PagerUnderline" }
      col = col + 1
      i = i + 3

    -- bold: x <BS> x
    elseif b == "\b" and a == c and c ~= "" then
      out[#out + 1] = a
      spans[#spans + 1] = { col, col + 1, "PagerBold" }
      col = col + 1
      i = i + 3
    else
      out[#out + 1] = a
      col = col + 1
      i = i + 1
    end
  end

  return table.concat(out), spans
end

local function render_buffer(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local new_lines = {}
  local line_spans = {}

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  for lnum, line in ipairs(lines) do
    local decoded, spans = decode_overstrike_line(line)
    new_lines[lnum] = decoded
    line_spans[lnum] = spans
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)

  for lnum, spans in ipairs(line_spans) do
    for _, span in ipairs(spans) do
      vim.api.nvim_buf_add_highlight(bufnr, ns, span[3], lnum - 1, span[1], span[2])
    end
  end
end

function M.setup()
  local bufnr = vim.api.nvim_get_current_buf()

  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false
  vim.bo[bufnr].filetype = "pager"

  vim.api.nvim_set_hl(0, "PagerBold", { bold = true })
  vim.api.nvim_set_hl(0, "PagerUnderline", { underline = true })

  render_buffer(bufnr)

  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].readonly = true

  vim.keymap.set("n", "q", vim.cmd.quit, {
    buffer = bufnr,
    silent = true,
  })
end

return M
