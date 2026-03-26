local util = require("config.util")

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if vim.fn.line([['"]]) > 1 and vim.fn.line([['"]]) <= vim.fn.line("$") then
      vim.api.nvim_win_set_cursor(0, vim.api.nvim_buf_get_mark(0, '"'))
    end
  end,
  group = vim.api.nvim_create_augroup("cursor_position", { clear = true }),
})

do
  local group = vim.api.nvim_create_augroup("terminal_insert", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    desc = "Automatically enter insert mode in terminal if not scrolled back",
    callback = function()
      if vim.o.buftype == "terminal" and vim.fn.line("$") == vim.fn.line("w$") then
        vim.cmd("startinsert")
      end
    end,
  })
end

do
  local timer_id = 0
  local group = vim.api.nvim_create_augroup("titlebar_naming", { clear = true })

  local function refresh_title_timer()
    if timer_id > 0 then
      vim.fn.timer_stop(timer_id)
    end

    timer_id = 0
    if vim.o.buftype == "terminal" then
      timer_id = vim.fn.timer_start(5000, refresh_title_timer, { ["repeat"] = -1 })
    end
  end

  vim.api.nvim_create_autocmd("VimLeave", {
    command = "set t_ts=\027k\027\\",
    group = group,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function()
      vim.o.title = true
      if vim.o.buftype == "terminal" then
        vim.o.titlestring = vim.b.term_title
      else
        local path = vim.fn.expand("%:p")
        if path == "" or vim.o.buftype == "help" then
          vim.o.titlestring = vim.fn.getcwd()
        else
          vim.o.titlestring = path
        end
      end

      refresh_title_timer()
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    callback = function()
      if timer_id > 0 then
        vim.fn.timer_stop(timer_id)
      end
    end,
  })
end

do
  local group = vim.api.nvim_create_augroup("doc", { clear = true })
  vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = { "*.doc", "*.docx", "*.odp", "*.odt" },
    callback = util.mk_fn(vim.cmd.silent, { "%!pandoc", '"%"', "--to=markdown", "-o", "/dev/stdout" }),
    group = group,
  })
  vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = { "*.rtf" },
    callback = util.mk_fn(
      vim.cmd.silent,
      { "%!textutil", '"%"', "-convert", "html", "-stdout", "\\|", "pandoc", "--from=html", "--to=markdown" }
    ),
    group = group,
  })
end

do
  local group = vim.api.nvim_create_augroup("crosshairs", { clear = true })
  vim.api.nvim_create_autocmd("WinEnter", {
    group = group,
    desc = "Highlight row and column on active window",
    callback = function()
      vim.opt_local.cursorline = true
      vim.opt_local.cursorcolumn = true
    end,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    desc = "Do not highlight row and column on inactive windows",
    callback = function()
      vim.opt_local.cursorline = false
      vim.opt_local.cursorcolumn = false
    end,
  })
end

do
  local group = vim.api.nvim_create_augroup("detection", { clear = true })
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.es6",
    command = "setfiletype javascript",
    group = group,
  })
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.gitconfig",
    command = "setfiletype gitconfig",
    group = group,
  })
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.snippets",
    command = "setfiletype snippets",
    group = group,
  })
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.html",
    group = group,
    callback = function()
      if #vim.fn.glob(vim.fn.getcwd() .. "/config.*") > 0 then
        vim.bo.filetype = "gohtmltmpl"
        vim.cmd("runtime! ftdetect/html.vim")
      end
    end,
  })
end
