local lsp = require("config.lsp")
local util = require("config.util")

local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap
local v = vim.v

keymap.set("n", "<Leader>jp", fn["jsonpath#echo"], { desc = "Print JSON path" })
keymap.set("n", "<Leader>jg", fn["jsonpath#goto"], { desc = "Go to JSON path" })

keymap.set("n", "you", cmd.UndotreeToggle, { desc = "Toggle Undotree sidebar" })
keymap.set("n", "]ou", cmd.UndotreeHide, { desc = "Hide Undotree sidebar" })
keymap.set("n", "[ou", cmd.UndotreeShow, { desc = "Show Undotree sidebar" })

vim.g.Undotree_CustomMap = function()
  keymap.set("n", "]c", "<Plug>UndotreeNextState", { buffer = true, desc = "Go to next state in the undotree" })
  keymap.set("n", "[c", "<Plug>UndotreePreviousState", { buffer = true, desc = "Go to previous state in the undotree" })
end

keymap.set("n", "yoS", fn["toggle#inccommand"], { desc = "Cycle through inccommand options" })
keymap.set(
  "n",
  "da<Space>",
  util.mk_fn(util.cursor_preserve_cmd, "%s/ \\+$//e"),
  { desc = "Delete all trailing whitespace" }
)

keymap.set("i", "jj", "<Esc>", { desc = "Return to normal mode via home row" })
keymap.set("i", "jkj", "j<Esc>", { desc = "Return to normal mode via home row after typing j" })
keymap.set("n", "<BS>", "<C-^>", { desc = "Use backspace to flip between files" })
keymap.set("n", "Q", "@@", { desc = "Repeat last macro (use gQ to go into ex mode)" })
keymap.set({ "n", "v" }, "v", "<C-V>", { desc = "Toggle visual block mode" })
keymap.set({ "n", "v" }, "<C-V>", "v", { desc = "Toggle visual mode" })

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

keymap.set("n", "<Leader>w", fn["buffer#update"], { desc = "Update buffer" })
keymap.set("n", "<Leader>q", fn["buffer#quit"], { desc = "Quit with warning" })
keymap.set("n", "<Leader><Leader>q", fn["buffer#update_and_quit"], { desc = "Update and quit" })

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
keymap.set("n", "<Leader>ga", cmd.Gwrite, { desc = "Stage changes in Git" })
keymap.set("n", "<Leader>gs", cmd.Git, { desc = "Git status" })
keymap.set("n", "<Leader>gps", util.mk_fn(cmd.Git, { "push", bang = true }), { desc = "Git push" })
keymap.set("n", "<Leader>gpf", util.mk_fn(cmd.Git, { "push --force", bang = true }), { desc = "Git force push" })
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
  cmd.Git("rebase -i HEAD~" .. v.count1)
end, { desc = "Rebase git" })

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
    find_command = { "git", "ls-files", "--ignored", "--exclude-standard", "--others" },
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

keymap.set("n", "<Leader>a", ":silent! grep<Space>", { desc = "Populate quickfix with grep" })
keymap.set("n", "<Leader>A", ":silent! grepadd<Space>", { desc = "Add to quickfix with grep" })
keymap.set("n", "<Leader><Leader>a", ":silent! lgrep<Space>", { desc = "Populate location list with grep" })
keymap.set("n", "<Leader><Leader>A", ":silent! lgrepadd<Space>", { desc = "Add to location list with grep" })
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
keymap.set("n", "[<M-p>", '"*[p', { remap = true, desc = "Put before using system clipboard" })
keymap.set("n", "]<M-p>", '"*]p', { remap = true, desc = "Put after using system clipboard" })

keymap.set("n", "<M-c>", function()
  fn.setreg("+", fn.getreg("0", 1))
end, { remap = true, desc = "Copy last yank to system clipboard" })
keymap.set("n", "<M-S-c>", function()
  fn.setreg("+", fn.getreg('"', 1))
end, { remap = true, desc = "Copy unnamed register to system clipboard" })
keymap.set("t", "<A-r>", function()
  return "<C-\\><C-N>" .. fn.nr2char(fn.getchar()) .. "pi"
end, { expr = true, desc = "Insert register into terminal buffer" })

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
        cmd("normal! " .. ({ line = "'[V']y", char = "`[v`]y", block = "`[<C-v>`]y", visual = "y" })[kind])
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

  make_search("/", "DuckDuckGo", "https://duckduckgo.com/?q=", true)
  make_search("g", "Github", "https://github.com/", false)
  make_search("d", "Dict", "https://dictionary.reference.com/browse/", false)
  make_search("c", "CanIUse", "https://caniuse.com/#search=", true)
  make_search("w", "Wikipedia", "https://en.wikipedia.org/wiki/Special:Search?search=", true)
  make_search("n", "NPM", "https://www.npmjs.com/search?q=", true)
end

keymap.set("v", "<C-/>", "<Esc>/\\%V", { desc = "Search within current selection" })
keymap.set("n", "<Leader>f", function()
  lsp.format_buffer()
end, { desc = "Format file" })
keymap.set("x", "<Leader>f", function()
  local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
  local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))
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
keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move window focus left" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move window focus down" })
keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move window focus down" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move window focus up" })
keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move window focus up" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move window focus right" })
keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move window focus right" })

keymap.set("t", ";;", "<C-\\><C-n>:", { desc = "Enter ex command" })
keymap.set("t", "jj", "<C-\\><C-n>", { desc = "Enter normal mode" })
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

keymap.set("n", "<A-h>", "<C-w><", { desc = "Resize window <" })
keymap.set("t", "<A-h>", "<C-\\><C-n><C-w><i", { desc = "Resize window <" })
keymap.set("n", "<A-j>", "<C-w>-", { desc = "Resize window -" })
keymap.set("t", "<A-j>", "<C-\\><C-n><C-w>-i", { desc = "Resize window -" })
keymap.set("n", "<A-k>", "<C-w>+", { desc = "Resize window +" })
keymap.set("t", "<A-k>", "<C-\\><C-n><C-w>+i", { desc = "Resize window +" })
keymap.set("n", "<A-l>", "<C-w>>", { desc = "Resize window >" })
keymap.set("t", "<A-l>", "<C-\\><C-n><C-w>>i", { desc = "Resize window >" })
keymap.set("n", "<A-=>", "<C-w>=", { desc = "Resize window =" })
keymap.set("t", "<A-=>", "<C-\\><C-n><C-w>=i", { desc = "Resize window =" })

keymap.set("n", "yo<Tab>", fn["toggle#tabs"], { desc = "Toggle tabs/spaces" })
keymap.set("n", "[o<Tab>", util.mk_fn(fn["toggle#tabs"], 1), { desc = "Use tabs" })
keymap.set("n", "]o<Tab>", util.mk_fn(fn["toggle#tabs"], 0), { desc = "Use spaces" })

keymap.set("n", "yoq", fn["toggle#quickfixList"], { desc = "Toggle quickfix visibility" })
keymap.set("n", "[oq", util.mk_fn(fn["toggle#quickfixList"], 1), { desc = "Show quickfix" })
keymap.set("n", "]oq", util.mk_fn(fn["toggle#quickfixList"], 0), { desc = "Hide quickfix" })

keymap.set("n", "yol", fn["toggle#locationList"], { desc = "Toggle location list visibility" })
keymap.set("n", "[ol", util.mk_fn(fn["toggle#locationList"], 1), { desc = "Show location list" })
keymap.set("n", "]ol", util.mk_fn(fn["toggle#locationList"], 0), { desc = "Hide location list" })

keymap.set("", "[<BS>", "<Plug>(IndentWiseBlockScopeBoundaryBegin)", { desc = "Move to beginning of block" })
keymap.set("", "]<BS>", "<Plug>(IndentWiseBlockScopeBoundaryEnd)", { desc = "Move to end of block" })

if
  (fn.isdirectory("/Applications/Setapp/Dash.app") == 1 or fn.isdirectory("/Applications/Dash.app") == 1)
  and not vim.env.SSH_CLIENT
then
  keymap.set("n", "gK", "<Plug>DashSearch", { desc = "Search using Dash" })
end
