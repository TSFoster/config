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
  local group = vim.api.nvim_create_augroup("terminal_osc7_cwd", { clear = true })
  vim.api.nvim_create_autocmd("TermRequest", {
    group = group,
    desc = "OSC 7: sync terminal buffer-local cwd (:bcd) to the shell's cwd",
    callback = function(ev)
      local dir, n = string.gsub(ev.data.sequence, "\027]7;file://[^/]*", "")
      if n > 0 and vim.fn.isdirectory(dir) == 1 then
        vim.b.shell_cwd = dir
        vim.cmd.bcd(dir)
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
        -- Prefer the shell's last-reported cwd (via OSC 7, see terminal_osc7_cwd)
        -- over the terminal's own OSC 2 title (vim.b.term_title): foreground
        -- programs like `claude` continuously rewrite the latter, which clobbers
        -- the pwd that tools like Timing.app need in the window title.
        vim.o.titlestring = vim.b.shell_cwd or vim.b.term_title
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
  local group = vim.api.nvim_create_augroup("auto_create_parent_dirs", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
    group = group,
    desc = "Create missing parent directories before writing local files",
    callback = function(args)
      local path = args.file
      if path == "" or path:match("://") then
        return
      end

      vim.fn.mkdir(vim.fn.fnamemodify(path, ":p:h"), "p")
    end,
  })
end

do
  local group = vim.api.nvim_create_augroup("detection", { clear = true })
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.j2",
    group = group,
    callback = function(args)
      local path = args.file
      local stem = path:gsub("%.j2$", "")
      local base_ft = vim.filetype.match({ filename = vim.fs.basename(stem), buf = args.buf })
        or vim.filetype.match({ filename = stem, buf = args.buf })

      vim.b[args.buf].jinja_base_ft = base_ft or ""
      vim.bo[args.buf].filetype = "jinja"
    end,
  })
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

do
  local group = vim.api.nvim_create_augroup("statusline_refresh", { clear = true })
  vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    group = group,
    desc = "Refresh the statusline when macro recording changes",
    callback = function()
      vim.cmd.redrawstatus()
    end,
  })
end
