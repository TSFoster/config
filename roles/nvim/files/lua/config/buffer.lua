local M = {}

function M.init_pager()
  vim.bo.bufhidden = "wipe"
  vim.keymap.set("n", "q", function()
    vim.cmd.lclose()
    vim.cmd.close()
  end, { buffer = true, silent = true, desc = "Close pager window" })
  vim.cmd.filetype("detect")
end

function M.wipeout(bang)
  local visible = {}

  for tab = 1, vim.fn.tabpagenr("$") do
    for _, buffer in ipairs(vim.fn.tabpagebuflist(tab)) do
      visible[buffer] = true
    end
  end

  local deleted = 0
  local skipped = 0

  for buffer = 1, vim.fn.bufnr("$") do
    if vim.fn.buflisted(buffer) == 1 and vim.fn.bufloaded(buffer) == 1 and not visible[buffer] then
      if vim.bo[buffer].modified then
        skipped = skipped + 1
      else
        deleted = deleted + 1
        vim.cmd.bwipeout({ args = { tostring(buffer) }, bang = bang })
      end
    end
  end

  local message = string.format("Deleted %d buffer%s", deleted, deleted == 1 and "" or "s")
  if skipped > 0 then
    message = string.format("%s, skipped %d modified buffer%s", message, skipped, skipped == 1 and "" or "s")
  end

  vim.api.nvim_echo({ { message } }, false, {})
end

return M
