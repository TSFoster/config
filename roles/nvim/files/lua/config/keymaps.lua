local toggle = require("config.toggle")
local tools = require("config.tools")
local lsp = require("config.lsp")
local util = require("config.util")

local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap
local v = vim.v

local function restart_with_temp_session()
  local session_file = fn.tempname() .. ".vim"

  cmd.mksession({ args = { fn.fnameescape(session_file) }, bang = true })
  cmd.restart({ args = { "source", fn.fnameescape(session_file) } })
end

-- Gracefully background the UI without pausing the Neovim process
keymap.set({ "n", "v", "x", "s", "o", "i", "l", "c" }, "<C-z>", "<Cmd>detach<CR>", { desc = "Detach UI" })

keymap.set("n", "<Leader>jp", fn["jsonpath#echo"], { desc = "Print JSON path" })
keymap.set("n", "<Leader>jg", fn["jsonpath#goto"], { desc = "Go to JSON path" })

keymap.set("n", "you", cmd.UndotreeToggle, { desc = "Toggle Undotree sidebar" })
keymap.set("n", "]ou", cmd.UndotreeHide, { desc = "Hide Undotree sidebar" })
keymap.set("n", "[ou", cmd.UndotreeShow, { desc = "Show Undotree sidebar" })

vim.g.Undotree_CustomMap = function()
  keymap.set("n", "]c", "<Plug>UndotreeNextState", { buffer = true, desc = "Go to next state in the undotree" })
  keymap.set("n", "[c", "<Plug>UndotreePreviousState", { buffer = true, desc = "Go to previous state in the undotree" })
end

keymap.set("n", "yoS", toggle.inccommand, { desc = "Cycle through inccommand options" })
keymap.set("n", "da<Space>", function()
  local trailspace = util.safe_require("mini.trailspace")
  if trailspace then
    trailspace.trim()
    trailspace.trim_last_lines()
    return
  end

  util.cursor_preserve_cmd("%s/ \\+$//e")
end, { desc = "Delete all trailing whitespace" })

keymap.set("i", "jj", "<Esc>", { desc = "Return to normal mode via home row" })
keymap.set("i", "jkj", "j<Esc>", { desc = "Return to normal mode via home row after typing j" })
keymap.set("n", "<BS>", "<C-^>", { desc = "Use backspace to flip between files" })
keymap.set("n", "Q", "@@", { desc = "Repeat last macro (use gQ to go into ex mode)" })

keymap.set("n", "j", function()
  return (v.count > 5) and ("m'" .. v.count .. "j") or "j"
end, { expr = true, desc = "Save big down movement to jumplist" })
keymap.set("n", "k", function()
  return (v.count > 5) and ("m'" .. v.count .. "k") or "k"
end, { expr = true, desc = "Save big up movement to jumplist" })

keymap.set("c", "%%", function()
  return fn.fnameescape(fn.expand("%:h") .. "/")
end, { expr = true, desc = "Expand current file's directory" })
keymap.set("c", "%p", function()
  return fn.fnameescape(fn.expand("%:p"))
end, { expr = true, desc = "Expand current file's full path" })
keymap.set("c", "%r", function()
  return fn.fnameescape(fn.expand("%"))
end, { expr = true, desc = "Expand current file's relative path" })

keymap.set("n", "<Leader>w", cmd.write, { desc = "Write buffer" })
keymap.set("n", "<Leader><Leader>w", cmd.wall, { desc = "Write all buffers" })
keymap.set("n", "<Leader><Leader>R", restart_with_temp_session, { desc = "Restart and restore from temp session" })
keymap.set("n", "<Leader>q", cmd.quit, { desc = "Quit window" })
keymap.set("n", "<Leader><Leader>q", cmd.qall, { desc = "Quit all windows" })
keymap.set("n", "<Leader>x", cmd.xit, { desc = "Write and quit window" })
keymap.set("n", "<Leader><Leader>x", cmd.xall, { desc = "Write and quit all windows" })

keymap.set("n", "<Leader>s", ":%s//g<Left><Left>", { desc = "Global substitution of whole buffer" })
keymap.set("v", "<Leader>s", ":s//g<Left><Left>", { desc = "Global substitution of selection" })
keymap.set("n", "<Leader>S", ":%S//g<Left><Left>", { desc = "Case-sensitive substitution of whole buffer" })
keymap.set("v", "<Leader>S", ":S//g<Left><Left>", { desc = "Case-sensitive substitution of selection" })

keymap.set("n", "<q", function()
  for _ = 1, v.count1 do
    cmd.colder()
  end
end, { desc = "Go to older error list" })
keymap.set("n", "<Q", function()
  while true do
    cmd.silent("colder")
  end
end, { desc = "Go to oldest error list" })
keymap.set("n", ">q", function()
  for _ = 1, v.count1 do
    cmd.cnewer()
  end
end, { desc = "Go to newer error list" })
keymap.set("n", ">Q", function()
  while true do
    cmd.silent("cnewer")
  end
end, { desc = "Go to newest error list" })

keymap.set("n", "<l", function()
  for _ = 1, v.count1 do
    cmd.lolder()
  end
end, { desc = "Go to older location list" })
keymap.set("n", "<L", function()
  while true do
    cmd.silent("lolder")
  end
end, { desc = "Go to oldest location list" })
keymap.set("n", ">l", function()
  for _ = 1, v.count1 do
    cmd.lnewer()
  end
end, { desc = "Go to newer location list" })
keymap.set("n", ">L", function()
  while true do
    cmd.silent("lnewer")
  end
end, { desc = "Go to newest location list" })

keymap.set("i", "<C-c>", "<Esc>", { desc = "Ensure InsertLeave is triggered with <C-c>" })
keymap.set("n", "gh", [[ciw<C-r>=printf('0x%x', <C-r>")<CR><Esc>]], { silent = true, desc = "Convert bases" })

keymap.set("n", "<Leader>gg", ":Git<Space>", { desc = "Make arbitrary Git command" })
keymap.set("n", "<Leader>ga", util.mk_fn(cmd.Gwrite), { desc = "Stage changes in Git" })
keymap.set("n", "<Leader>gs", util.mk_fn(cmd.Git), { desc = "Git status" })
keymap.set("n", "<Leader>gps", util.mk_fn(cmd.Git, { "push", bang = true }), { desc = "Git push" })
keymap.set(
  "n",
  "<Leader>gpf",
  util.mk_fn(cmd.Git, { "push --force-with-lease", bang = true }),
  { desc = "Git force push" }
)
keymap.set("n", "<Leader>gpl", util.mk_fn(cmd.Git, "pull"), { desc = "Git pull" })
keymap.set("n", "<Leader>gco", util.mk_fn(cmd.Git, "commit"), { desc = "Git commit" })
keymap.set("n", "<Leader>gca", util.mk_fn(cmd.Git, "commit --amend"), { desc = "Amend git commit" })
keymap.set(
  "n",
  "<Leader>gcA",
  util.mk_fn(cmd.Git, "commit --amend --no-edit"),
  { desc = "Amend git commit without edit" }
)
keymap.set("n", "<Leader>gre", function()
  if v.count == 0 then
    cmd.Git("rebase -i --root")
  else
    cmd.Git("rebase -i HEAD~" .. v.count)
  end
end, { desc = "Rebase git" })

keymap.set("n", "<Leader>gv", function()
  cmd.Git({ mods = { vertical = true, split = "topleft" }, args = { "log --graph --oneline" } })
  cmd.resize({ mods = { vertical = true }, args = { "75" } })
end, { desc = "Open git log" })
keymap.set("n", "<Leader>gV", function()
  cmd.Git({ mods = { vertical = true, split = "topleft" }, args = { "log --graph --oneline -- %" } })
  cmd.resize({ mods = { vertical = true }, args = { "75" } })
end, { desc = "Open git log for current file" })
keymap.set("n", "<Leader>gf", function()
  cmd.Git({ mods = { vertical = true, split = "topleft" }, args = { "log --graph --oneline --stat" } })
  cmd.resize({ mods = { vertical = true }, args = { "75" } })
end, { desc = "Open git log with stats" })
keymap.set("n", "<Leader>gF", function()
  cmd.Git({ mods = { vertical = true, split = "topleft" }, args = { "log --graph --oneline --stat -- %" } })
  cmd.resize({ mods = { vertical = true }, args = { "75" } })
end, { desc = "Open git log with stats for current file" })
-- TODO Replace with https://github.com/rbong/vim-flog, maybe

keymap.set({ "x", "o" }, "i,", "<Plug>(swap-textobject-i)", { remap = true, desc = "Delimited item i text object" })
keymap.set({ "x", "o" }, "a,", "<Plug>(swap-textobject-a)", { remap = true, desc = "Delimited item a text object" })

local telescope_builtin = util.safe_require("telescope.builtin")
local function fd_command(kind)
  local command = {
    "fd",
    "--color=never",
    "--exclude=node_modules",
    "--exclude=.git",
    "--exclude=elm-stuff",
    "--exclude=bower_components",
    "--exclude=target",
    "--exclude=.DS_Store",
    "--hidden",
  }
  if kind == "directory" then
    table.insert(command, "--type")
    table.insert(command, "directory")
  else
    table.insert(command, "--type")
    table.insert(command, "file")
  end

  return command
end

local function telescope(name, opts)
  return function()
    if not telescope_builtin then
      return
    end

    telescope_builtin[name](opts or {})
  end
end

local function telescope_files(kind, relative)
  return function()
    if not telescope_builtin then
      return
    end

    local cwd = relative and util.current_buffer_dir() or util.project_root()
    telescope_builtin.find_files({
      cwd = cwd,
      find_command = fd_command(kind),
      prompt_title = relative and ("Find " .. kind .. " in " .. fn.fnamemodify(cwd, ":~")) or ("Find " .. kind .. "s"),
    })
  end
end

keymap.set("n", "<Leader>gi", function()
  if not telescope_builtin then
    return
  end

  telescope_builtin.find_files({
    cwd = util.project_root(),
    find_command = {
      "git",
      "ls-files",
      "--ignored",
      "--exclude-standard",
      "--others",
    },
    prompt_title = "Git ignored files",
  })
end, { desc = "Find git ignored files" })
keymap.set("n", "<Leader>ge", telescope("git_status"), { desc = "Git status picker" })
keymap.set("n", "<Leader>gE", telescope("git_files"), { desc = "Git files" })
keymap.set("n", "<Leader>gC", telescope("git_commits"), { desc = "Git commits" })

keymap.set("n", "<Leader>d", telescope_files("directory", false), { desc = "Find directories" })
keymap.set("n", "<Leader>D", telescope_files("directory", true), { desc = "Find directories relative to buffer" })
keymap.set("n", "<Leader>e", telescope_files("file", false), { desc = "Find files" })
keymap.set("n", "<Leader>E", telescope_files("file", true), { desc = "Find files relative to buffer" })
keymap.set("n", "<Leader>h:", telescope("command_history"), { desc = "Command history" })
keymap.set("n", "<Leader>h/", telescope("search_history"), { desc = "Search history" })
keymap.set("n", "<Leader>mr", telescope("oldfiles"), { desc = "Recent files" })
keymap.set("n", "<Leader>ms", function()
  local sessions = util.safe_require("mini.sessions")
  if sessions then
    sessions.select("read")
  end
end, { desc = "Read session" })
keymap.set("n", "<Leader>mS", function()
  local sessions = util.safe_require("mini.sessions")
  if not sessions then
    return
  end

  vim.ui.input({ prompt = "Session name: " }, function(input)
    if not input or input == "" then
      return
    end

    sessions.write(input)
  end)
end, { desc = "Write session" })
keymap.set("n", "<Leader>md", function()
  local sessions = util.safe_require("mini.sessions")
  if sessions then
    sessions.select("delete")
  end
end, { desc = "Delete session" })
keymap.set("n", "<Leader>mv", function()
  local visits = util.safe_require("mini.visits")
  if visits then
    visits.select_path(fn.getcwd())
  end
end, { desc = "Select visited file in cwd" })
keymap.set("n", "<Leader>mV", function()
  local visits = util.safe_require("mini.visits")
  if visits then
    visits.select_path("")
  end
end, { desc = "Select visited file from all projects" })
keymap.set("n", "[v", function()
  local visits = util.safe_require("mini.visits")
  if visits then
    visits.iterate_paths("forward", fn.getcwd())
  end
end, { desc = "Older visited file in cwd" })
keymap.set("n", "]v", function()
  local visits = util.safe_require("mini.visits")
  if visits then
    visits.iterate_paths("backward", fn.getcwd())
  end
end, { desc = "Newer visited file in cwd" })
keymap.set("n", "<Leader>he", telescope("help_tags"), { desc = "Help tags" })
keymap.set("n", "<Leader>ta", telescope("tags"), { desc = "Tags" })
keymap.set("n", "<Leader>b", telescope("buffers"), { desc = "Buffers" })
keymap.set("n", "<Leader>B", telescope("current_buffer_fuzzy_find"), { desc = "Search lines in current buffer" })
keymap.set("n", "<Leader>l", telescope("live_grep"), { desc = "Telescope live grep" })
keymap.set("n", "<Leader><Leader><Leader>", telescope("builtin"), { desc = "Telescope builtins" })

keymap.set("n", "yot", function()
  if not telescope_builtin then
    return
  end

  if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/documentSymbol" }) > 0 then
    telescope_builtin.lsp_document_symbols()
  else
    telescope_builtin.treesitter()
  end
end, { desc = "Document symbols" })
keymap.set("n", "]ot", function()
  if telescope_builtin then
    telescope_builtin.lsp_dynamic_workspace_symbols()
  end
end, { desc = "Workspace symbols" })
keymap.set("n", "[ot", function()
  if telescope_builtin then
    telescope_builtin.treesitter()
  end
end, { desc = "Treesitter symbols" })

keymap.set("n", "<Leader>a", ":Grep<Space>", { desc = "Populate quickfix with grep" })
keymap.set("n", "<Leader>A", ":Grepadd<Space>", { desc = "Add to quickfix with grep" })
keymap.set("n", "<Leader><Leader>a", ":Lgrep<Space>", { desc = "Populate location list with grep" })
keymap.set("n", "<Leader><Leader>A", ":Lgrepadd<Space>", { desc = "Add to location list with grep" })
keymap.set("n", "<Leader>pu", function()
  vim.pack.update()
end, { desc = "Update vim.pack plugins" })

keymap.set("n", "Y", "y$", { remap = true, desc = "Make Y work more like D and C" })

keymap.set("i", "<M-y>", '<C-o>"*y', { remap = true, desc = "Yank using system clipboard" })
keymap.set({ "v", "n" }, "<M-y>", '"*y', { remap = true, desc = "Yank using system clipboard" })
keymap.set("i", "<M-y><M-y>", '<C-o>"*yy', { remap = true, desc = "Yank line using system clipboard" })
keymap.set("n", "<M-y><M-y>", '"*yy', { remap = true, desc = "Yank line using system clipboard" })
keymap.set("i", "<M-S-y>", '<C-o>"*Y', { remap = true, desc = "Yank to end of line using system clipboard" })
keymap.set("n", "<M-S-y>", '"*Y', { remap = true, desc = "Yank to end of line using system clipboard" })
keymap.set({ "i", "c" }, "<M-p>", "<C-r>*", { remap = true, desc = "Put using system clipboard" })
keymap.set({ "v", "n" }, "<M-p>", '"*p', { remap = true, desc = "Put using system clipboard" })
keymap.set("t", "<M-p>", "<A-r>*", { remap = true, desc = "Put using system clipboard" })
keymap.set("i", "<M-S-p>", '<C-o>"*P', { remap = true, desc = "Put before using system clipboard" })
keymap.set("n", "<M-S-p>", '"*P', { remap = true, desc = "Put before using system clipboard" })
keymap.set("n", "[<M-p>", ":put! *<CR>", { remap = true, desc = "Put before using system clipboard" })
keymap.set("n", "]<M-p>", ":put *<CR>", { remap = true, desc = "Put after using system clipboard" })
keymap.set("n", "[p", function()
  cmd.put({ reg = v.register, bang = true })
end, { desc = "Linewise put before" })
keymap.set("n", "]p", function()
  cmd.put({ reg = v.register })
end, { desc = "Linewise put after" })

keymap.set("n", "<Leader>cc", function()
  fn.setreg("+", fn.getreg("0", 1))
end, { remap = true, desc = "Copy last yank to system clipboard" })
keymap.set("n", "<Leader>cu", function()
  fn.setreg("+", fn.getreg('"', 1))
end, { remap = true, desc = "Copy unnamed register to system clipboard" })
keymap.set("t", "<A-r>", function()
  local char = fn.nr2char(fn.getchar())
  local chan = vim.bo[vim.api.nvim_get_current_buf()].channel
  fn.chansend(chan, fn.getreg(char))
end, { desc = "Insert register into terminal buffer" })

if not vim.env.SSH_CLIENT then
  local function char_to_hex(char)
    return string.format("%%%02X", string.byte(char))
  end

  local function urlencode(url)
    if url == nil then
      return
    end

    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
  end

  local open = "start"
  if fn.has("unix") == 1 then
    open = "xdg-open"
  end
  if fn.has("mac") == 1 then
    open = "open"
  end

  Search = {}
  local function make_search(char, name, prefix, escape_selection)
    Search[name] = function(kind, text)
      local selection = vim.o.selection
      local register = fn.getreg("@", 1)
      vim.o.selection = "inclusive"
      kind = kind or "visual"

      if text then
        fn.setreg("@", text)
      else
        cmd.normal({
          bang = true,
          args = {
            ({
              line = "'[V']y",
              char = "`[v`]y",
              block = "`[<C-v>`]y",
              visual = "y",
            })[kind],
          },
        })
      end

      local term = escape_selection and urlencode(fn.getreg("@", 0)) or fn.getreg("@", 0)
      fn.system(open .. " '" .. prefix .. term .. "'")

      vim.o.selection = selection
      fn.setreg("@", register)
    end

    local function operator()
      vim.o.operatorfunc = "v:lua.Search." .. name
      return "g@"
    end

    keymap.set("n", "<Leader>/" .. char, operator, { expr = true, desc = "Search " .. name .. " using motion" })
    keymap.set("v", "<Leader>/" .. char, Search[name], { desc = "Search " .. name .. " with selection" })
  end

  make_search("/", "Kagi", "https://kagi.com/search?q=", true)
  make_search("g", "Github", "https://github.com/", false)
  make_search("d", "Dict", "https://dictionary.reference.com/browse/", false)
  make_search("c", "CanIUse", "https://caniuse.com/#search=", true)
  make_search("w", "Wikipedia", "https://en.wikipedia.org/wiki/Special:Search?search=", true)
  make_search("n", "NPM", "https://www.npmjs.com/search?q=", true)
end

PandocCopy = {}
local function make_pandoc_copy(char, format, name, font_size)
  PandocCopy[name] = function(kind)
    local register = PandocCopy.last_register or (v.register == '"' and "*" or v.register)
    PandocCopy.last_register = nil

    local selection = vim.o.selection
    local orig_reg_contents = fn.getreg("@", 1)
    local orig_reg_type = fn.getregtype("@")
    vim.o.selection = "inclusive"
    kind = kind or "visual"

    cmd.normal({
      bang = true,
      args = {
        ({
          line = "'[V']y",
          char = "`[v`]y",
          block = "`[<C-v>`]y",
          visual = "y",
        })[kind],
      },
    })

    local text = fn.getreg("@", 0)

    vim.o.selection = selection
    fn.setreg("@", orig_reg_contents, orig_reg_type)

    util.copy_pandoc(text, format, register, font_size)
  end

  local function operator()
    PandocCopy.last_register = v.register == '"' and "*" or v.register
    vim.o.operatorfunc = "v:lua.PandocCopy." .. name
    return "g@"
  end

  keymap.set("n", "<Leader>c" .. char, operator, { expr = true, desc = "Copy " .. name .. " using motion" })
  keymap.set("v", "<Leader>c" .. char, PandocCopy[name], { desc = "Copy " .. name .. " with selection" })
end

make_pandoc_copy("h", "html", "HTML")
make_pandoc_copy("r", "rtf", "RTF", "16pt")

keymap.set("v", "<C-/>", "<Esc>/\\%V", { desc = "Search within current selection" })
keymap.set("n", "<Leader>f", function()
  lsp.format_buffer()
end, { desc = "Format file" })
keymap.set("x", "<Leader>f", function()
  local start_line, start_col = table.unpack(vim.api.nvim_buf_get_mark(0, "<"))
  local end_line, end_col = table.unpack(vim.api.nvim_buf_get_mark(0, ">"))
  lsp.format_buffer({
    start = { start_line, start_col },
    ["end"] = { end_line, end_col },
  })
end, { desc = "Format selection" })
keymap.set("n", "<Leader><Leader>f", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { "quickfix" },
    },
  })
end, { desc = "Apply first quickfix action" })
keymap.set("n", "<Leader><Leader>F", function()
  vim.lsp.buf.code_action({
    context = {
      only = { "quickfix" },
    },
  })
end, { desc = "Show quickfix actions" })

keymap.set("x", ".", ":normal .<CR>", { desc = "Repeat on each line of visual selection" })

keymap.set("n", "yof", function()
  if vim.g.should_autoformat == nil then
    vim.g.should_autoformat = true
  end
  vim.g.should_autoformat = not vim.g.should_autoformat
  print(vim.g.should_autoformat and "Autoformat globally" or "Do not autoformat globally")
end, { desc = "Toggle autoformatting on save globally" })
keymap.set("n", "[of", function()
  vim.g.should_autoformat = false
  print("Do not autoformat globally")
end, { desc = "Turn off autoformatting on save globally" })
keymap.set("n", "]of", function()
  vim.g.should_autoformat = true
  print("Autoformat globally")
end, { desc = "Turn on autoformatting on save globally" })
keymap.set("n", "yoF", function()
  if vim.b.should_autoformat == nil then
    vim.b.should_autoformat = true
  end
  vim.b.should_autoformat = not vim.b.should_autoformat
  print(vim.b.should_autoformat and "Autoformat this buffer" or "Do not autoformat this buffer")
end, { desc = "Toggle autoformatting on save for this buffer" })
keymap.set("n", "[oF", function()
  vim.b.should_autoformat = false
  print("Do not autoformat this buffer")
end, { desc = "Turn off autoformatting on save for this buffer" })
keymap.set("n", "]oF", function()
  vim.b.should_autoformat = true
  print("Autoformat this buffer")
end, { desc = "Turn on autoformatting on save for this buffer" })

keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move window focus left" })
keymap.set("t", "<C-h>", function()
  cmd.wincmd("h")
end, { desc = "Move window focus left" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move window focus down" })
keymap.set("t", "<C-j>", function()
  cmd.wincmd("j")
end, { desc = "Move window focus down" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move window focus up" })
keymap.set("t", "<C-k>", function()
  cmd.wincmd("k")
end, { desc = "Move window focus up" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move window focus right" })
keymap.set("t", "<C-l>", function()
  cmd.wincmd("l")
end, { desc = "Move window focus right" })

keymap.set("t", ";;", "<C-\\><C-n>:", { desc = "Enter ex command" })
keymap.set("t", "jj", "<C-\\><C-n>", { desc = "Enter normal mode" })
keymap.set("t", "<A-\\>", function()
  local char = fn.getchar()
  local chan = vim.bo[vim.api.nvim_get_current_buf()].channel
  local bytes
  if type(char) == "number" and char > 0 then
    if char >= 128 and char < 256 then
      bytes = "\x1b" .. fn.nr2char(char - 128)
    else
      bytes = fn.nr2char(char)
    end
  elseif type(char) == "string" and char:sub(1, 2) == "\x80\xfc" then
    -- \x80\xfc + modifier_byte + key: Vim's internal modifier-key encoding
    local mod = char:byte(3)
    local key = char:sub(4)
    local is_ctrl = bit.band(mod, 0x04) ~= 0 -- MOD_MASK_CTRL
    local is_alt = bit.band(mod, 0x08) ~= 0 -- MOD_MASK_ALT
    local inner = is_ctrl and fn.nr2char(string.byte(key) % 32) or key
    bytes = is_alt and ("\x1b" .. inner) or inner
  end
  if bytes then
    fn.chansend(chan, bytes)
  end
end, { desc = "Send next keystroke literally to terminal" })
keymap.set("t", "<A-Space>", "<C-\\><C-n><Leader>", { remap = true, desc = "Leader" })
keymap.set("n", "<A-Space>", "<Leader>", { remap = true, desc = "Leader" })

keymap.set("n", "<Leader>nj", util.mk_fn(cmd, "rightbelow new"), { desc = "Open new buffer below" })
keymap.set("n", "<Leader>nk", util.mk_fn(cmd, "leftabove new"), { desc = "Open new buffer above" })
keymap.set("n", "<Leader>nl", util.mk_fn(cmd, "rightbelow vnew"), { desc = "Open new buffer to right" })
keymap.set("n", "<Leader>nh", util.mk_fn(cmd, "leftabove vnew"), { desc = "Open new buffer to left" })
keymap.set("n", "<Leader>nn", cmd.enew, { desc = "Open new buffer in window" })
keymap.set("n", "<Leader>nN", cmd.tabnew, { desc = "Open new buffer in new tab" })

keymap.set("n", "<Leader>tj", util.mk_fn(cmd, "botright horizontal terminal"), { desc = "Open terminal session below" })
keymap.set("n", "<Leader>tk", util.mk_fn(cmd, "topleft horizontal terminal"), { desc = "Open terminal session above" })
keymap.set(
  "n",
  "<Leader>tl",
  util.mk_fn(cmd, "botright vertical terminal"),
  { desc = "Open terminal session to right" }
)
keymap.set("n", "<Leader>th", util.mk_fn(cmd, "topleft vertical terminal"), { desc = "Open terminal session to left" })
keymap.set("n", "<Leader>tT", util.mk_fn(cmd, "tab terminal"), { desc = "Open terminal session in new tab" })
keymap.set("n", "<Leader>tt", cmd.terminal, { desc = "Open terminal session in window" })

keymap.set({ "n", "t", "i" }, "<M-/>", function()
  tools.focus("yazi", "yazi")
end, { desc = "Open Yazi" })
keymap.set({ "n", "t", "i" }, "<M-c>", function()
  tools.focus("claude", "claude")
end, { desc = "Open Claude Code" })
keymap.set({ "n", "t", "i" }, "<M-o>", function()
  tools.focus("codex", fn.stdpath("config") .. "/bin/asdf-codex")
end, { desc = "Open Codex" })
keymap.set({ "n", "t", "i" }, "<M-g>", function()
  tools.focus("gemini", "agy")
end, { desc = "Open Gemini" })
keymap.set({ "n", "t", "i" }, "<M-s>", function()
  tools.focus("shell_1", vim.env.SHELL or "bash")
end, { desc = "Open Shell" })
for i = 1, 9 do
  keymap.set({ "n", "t", "i" }, "<M-" .. i .. ">", function()
    tools.focus("shell_" .. i, vim.env.SHELL or "bash")
  end, { desc = "Open Shell " .. i })
end
keymap.set({ "n", "t", "i" }, "<M-d>", function()
  local dev_cmd = vim.g.dev_cmd or "make dev"
  tools.focus("dev", dev_cmd)
end, { desc = "Open dev server" })

keymap.set({ "n", "t", "i" }, "<M-u>", tools.unfocus, { desc = "Leave the tools tab" })

keymap.set({ "n", "t", "i" }, "<M-U>", tools.close_all, { desc = "Close all tools and tab" })

keymap.set({ "n", "t", "i" }, "<M-i>", function()
  cmd.CodeCompanionChat("Toggle")
end, { desc = "Toggle CodeCompanion chat" })
keymap.set("n", "<Leader>i", cmd.CodeCompanionActions, { desc = "CodeCompanion actions" })
keymap.set("x", "gi", function()
  cmd.CodeCompanionChat("Add")
end, { desc = "Add selection to CodeCompanion chat" })

keymap.set("n", "<A-h>", "<C-w><", { desc = "Resize window <" })
keymap.set("t", "<A-h>", function()
  cmd.wincmd("<")
end, { desc = "Resize window <" })
keymap.set("n", "<A-j>", "<C-w>-", { desc = "Resize window -" })
keymap.set("t", "<A-j>", function()
  cmd.wincmd("-")
end, { desc = "Resize window -" })
keymap.set("n", "<A-k>", "<C-w>+", { desc = "Resize window +" })
keymap.set("t", "<A-k>", function()
  cmd.wincmd("+")
end, { desc = "Resize window +" })
keymap.set("n", "<A-l>", "<C-w>>", { desc = "Resize window >" })
keymap.set("t", "<A-l>", function()
  cmd.wincmd(">")
end, { desc = "Resize window >" })
keymap.set("n", "<A-=>", "<C-w>=", { desc = "Resize window =" })
keymap.set("t", "<A-=>", function()
  cmd.wincmd("=")
end, { desc = "Resize window =" })

for i = 1, 9 do
  keymap.set({ "n", "t", "i" }, "<C-" .. i .. ">", function()
    cmd.tabnext(i)
  end, { desc = "Go to tab " .. i })
end
keymap.set({ "n", "t", "i" }, "<C-->", cmd.tabprevious, { desc = "Go to previous tab" })
keymap.set({ "n", "t", "i" }, "<C-=>", cmd.tabnext, { desc = "Go to next tab" })

keymap.set("n", "yo<Tab>", toggle.tabs, { desc = "Toggle tabs/spaces" })
keymap.set("n", "[o<Tab>", util.mk_fn(toggle.tabs, 1), { desc = "Use tabs" })
keymap.set("n", "]o<Tab>", util.mk_fn(toggle.tabs, 0), { desc = "Use spaces" })

keymap.set("n", "yoq", toggle.quickfix_list, { desc = "Toggle quickfix visibility" })
keymap.set("n", "[oq", util.mk_fn(toggle.quickfix_list, 1), { desc = "Show quickfix" })
keymap.set("n", "]oq", util.mk_fn(toggle.quickfix_list, 0), { desc = "Hide quickfix" })

keymap.set("n", "yom", function()
  local mini_notify = util.safe_require("mini.notify")
  if not mini_notify then
    return
  end

  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local buf_name = vim.api.nvim_buf_get_name(buf_id)
    if buf_name:match("^mininotify://") then
      vim.api.nvim_buf_delete(buf_id, { force = true })
      return
    end
  end

  mini_notify.show_history()
end, { desc = "Toggle notification history" })

keymap.set("n", "yol", toggle.location_list, { desc = "Toggle location list visibility" })
keymap.set("n", "[ol", util.mk_fn(toggle.location_list, 1), { desc = "Show location list" })
keymap.set("n", "]ol", util.mk_fn(toggle.location_list, 0), { desc = "Hide location list" })

keymap.set("", "[<BS>", "<Plug>(IndentWiseBlockScopeBoundaryBegin)", { desc = "Move to beginning of block" })
keymap.set("", "]<BS>", "<Plug>(IndentWiseBlockScopeBoundaryEnd)", { desc = "Move to end of block" })

keymap.set({ "n", "t", "i" }, "<M-v>", vim.cmd.vsplit, { desc = ":vsplit" })
keymap.set({ "n", "t", "i" }, "<M-x>", vim.cmd.split, { desc = ":split" })
