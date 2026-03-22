-- TODO investigate https://github.com/coachshea/neo-pipe
-- TODO replace coc.nvim!? coq_nvim, telescope.nvim, mfussenegger/nvim-lint, jose-elias-elvarez/null-ls.nvim, neovim/nvim-lspconfig, kosayoda/nvim-lightbulb, mhartington/formatter.nvim
-- TODO investigate turning off termguicolors permanently or selectively turn on
-- TODO :term clipboard/fish clipboard/vim clipboard/system clipboard

-- GLOBAL VARIABLES

opt = vim.opt
opt_local = vim.opt_local
g = vim.g
b = vim.b
v = vim.v
o = vim.o
api = vim.api
env = vim.env
call = vim.call
cmd = vim.cmd
keymap = vim.keymap
fn = vim.fn
has = fn.has
wait = vim.wait

local mkFn = function(f, a) return function() f(a) end end

local cursorPreserveCmd = function(str)
  local slashReg = fn.getreg("/", 1)
  local line = fn.line(".")
  local col = fn.col(".")
  cmd(str)
  fn.setreg("/", slashReg)
  fn.cursor(line, col)
end


-- OPTIONS

opt.backupdir:remove "."                                          -- Keep all backups in XDG_DATA_HOME. Backups in file’s own dir can cause issues in some cases anyway
opt.breakindent = true; opt.showbreak =
"… "                                                            -- Visually indent wrapped lines to match whitespace and prepend with ‘… ’
opt.cmdheight = 2                                                 -- Bit of space for messages
opt.expandtab = true                                              -- Spaces by default
opt.fixendofline = false                                          -- Leave missing EOLs alone, it makes for a messy diff when dealing with others’ code
opt.formatprg =
"par rqw80"                                                       -- Let’s just assume par is installed and in PATH for formatting prose …
opt.hidden = true                                                 -- Allow edited buffers to get hidden
opt.ignorecase = true; opt.smartcase = true                       -- Ignore case unless the search contains uppercase chars
opt.lazyredraw = true                                             -- Can speed things up considerably when using relativenumber and terminal splits etc.
opt.list = true; opt.listchars = { tab = "▸ ", trail = "·" }   -- Show tabs and trailing spaces
opt.path:append "**"                                              -- Search whole project dir for possible matches when using e.g. gf or :find
opt.relativenumber = true; opt.number = true                      -- Use relative numbers apart from the line we’re on
opt.scrolloff = 5                                                 -- Start scrolling when cursor reaches 5 lines from edge
opt.shortmess:append "c"                                          -- Don’t show messages related to completion menu in command line
opt.spelllang = "en_gb"                                           -- British English by default
opt.splitbelow = true; opt.splitright = true                      -- Choose our default split directions
opt.undofile = true; opt.undolevels = 1000; opt.undoreload = 1000 -- Store 1000 undos in a file and keep them on buffer reload
opt.updatetime = 300                                              -- Write to swap file pretty quickly. Disks are fast these days and plugins may use info in them
opt.viminfo =
"'1000,f1,<500"                                                   -- Keep marks for 1000 files, store global marks, limit viminfo to 500 lines
opt.wildignorecase = true                                         -- ignore case when completing files & directories
opt.wildmode = { "list", "full" }                                 -- On first <tab>, show all available options, cycle through options on subsequent <tab>s
opt.inccommand =
"nosplit"                                                         -- Show search and replace as you type, but no previews for changes off-screen
opt.nrformats = { "bin", "hex", "unsigned", "blank" }             -- Recognise 0b, 0x as binary and hex, and treat integers as unsigned unless whitespace + ‘-’

g.mapleader =
" " -- Space is a great <Leader>. It is very accesible and the hands are used to hitting it frequently without moving

cmd.colorscheme "catppuccin"


-- COC EXTENSIONS

g.coc_global_extensions = {
  "@yaegassy/coc-ansible",
  "coc-css",
  "coc-deno",
  "coc-diagnostic", -- TODO expand use?
  "coc-dictionary",
  "coc-elixir",
  "coc-emmet",
  "coc-emoji",
  "coc-eslint",
  "coc-fish",
  "coc-flow",
  "coc-git",
  "coc-gitignore",
  "coc-gocode",
  "coc-highlight",
  "coc-html",
  "coc-json",
  "coc-lists",
  "coc-lua",
  "coc-markdownlint",
  "coc-phpls",
  "coc-prettier",
  "coc-python",
  "coc-rls",
  "coc-rust-analyzer",
  "coc-snippets",
  "coc-solargraph",
  "coc-svg",
  "coc-syntax",
  "coc-tag",
  "coc-tsserver",
  "coc-vimlsp",
  "coc-word",
  "coc-xml",
  "coc-yaml",
  "coc-yank",
}

-- HOST PROGS


g.python3_host_prog = "~/.asdf/shims/python3"
g.node_host_prog = "~/.asdf/installs/nodejs/22.2.0/bin/neovim-node-host"
g.ruby_host_prog = "~/.asdf/shims/neovim-ruby-host"
g.loaded_perl_provider = 0

-- PLUGIN/EXTERNAL TOOL CONFIG

g.loaded_netrwPlugin = 1          -- Disable netrw (in favour of dirvish)

g.undotree_WindowLayout = 2       -- Tree on left, diff below it
g.undotree_ShortIndicators = 1    -- "5 s" is just as descriptive as "5 seconds ago"
g.undotree_SetFocusWhenToggle = 1 -- Take focus when toggling. I only have tree open when I want to use it, and moving to it with mappings can change which buffer the tree is displaying

g.tagbar_autoclose = 1            -- Tagbar only open when using

g.camelcasemotion_key = "\\"      -- Use backslash in motions within mixedCaseWords

g.kickfix_zebra = 0               -- Deactivate the zebra stripes, they're visual clutter

keymap.set("n", "go", "<Plug>SortMotion", { remap = true, desc = "Sort motion" })
keymap.set("x", "go", "<Plug>SortMotionVisual", { remap = true, desc = "Sort selection" })
keymap.set("n", "gO", "<Plug>SortLines", { remap = true, desc = "Sort <count> lines" })

g.polyglot_disabled = { "cryptol" } -- Always caused issues for me. TODO remove polyglot anyway (see above)

g.dispatch_neovim_new_cmd =
"vnew"                 -- Dispatch should use vsplits

g.rustfmt_autosave = 1 -- Format rust when saving

g.EditorConfig_exclude_patterns = {}
g.EditorConfig_exclude_patterns[1] =
"fugitive://.*" -- Doesn’t make sense for EditorConfig to match fugitive buffers
g.EditorConfig_exclude_patterns[2] =
"scp://.*"      -- Don’t try to load .editorconfig files on remote servers

g.switch_mapping = "g."; g.switch_reverse_mapping =
"g,"                                                             -- Default of "gs" interferes with switch, '.' and ',' unshifted versions of'>' and '<', so makes some logical sense

g.coc_status_error_sign = ">>"; g.coc_status_warning_sign = "⚠ " -- Signs that appear in the gutter

g.lion_squeeze_spaces = 1                                        -- Remove extra spaces when aligning with vim-lion

keymap.set("n", "<Leader>jp", fn["jsonpath#echo"], { desc = "Print JSON path" })
keymap.set("n", "<Leader>jg", fn["jsonpath#goto"], { desc = "Go to JSON path" })

g.projectionist_heuristics = {
  ["elm.json"] = {
    ["*.elm"] = {
      repl = "elm repl"
    }
  }
}

-- Overrides vim-unimpaired’s map for toggling cursorcolumn
keymap.set("n", "you", cmd.UndotreeToggle, { desc = "Toggle Undotree sidebar" })
keymap.set("n", "]ou", cmd.UndotreeHide, { desc = "Hide Undotree sidebar" })
keymap.set("n", "[ou", cmd.UndotreeShow, { desc = "Show Undotree sidebar" })


g.Undotree_CustomMap = function()
  keymap.set("n", "]c", "<Plug>UndotreeNextState", { buffer = true, desc = "Go to next state in the undotree" })
  keymap.set("n", "[c", "<Plug>UndotreePreviousState", { buffer = true, desc = "Go to previous state in the undotree" })
end


-- STATUSLINE

function statusline_coc_status()
  if not fn.exists("*coc#status") then return "" end
  local status = fn["coc#status"]()
  if status == "" then return "" end
  return " [" .. status .. "]"
end

function statusline_current_function()
  if not b.coc_current_function or b.coc_current_function == "" then return "" end
  return ":" .. b.coc_current_function
end

function statusline_color_by_mode(mode)
  local mode_name = ({ n = "Normal", no = "Normal", i = "Insert", v = "Visual", V = "Visual", [""] = "Visual", t =
  "Term" })[mode] or ""
  cmd("highlight! link User1 StatusLine" .. mode_name)
  return ""
end

o.statusline =
"%{v:lua.statusline_color_by_mode(mode())}%1*"                          -- Hack(?) to change statusbar color based on mode
o.statusline = o.statusline .. "%{v:lua.statusline_coc_status()}"       -- coc.nvim
o.statusline = o.statusline .. " %<%F"                                  -- File path
o.statusline = o.statusline .. "%{v:lua.statusline_current_function()}" -- coc.nvim
o.statusline = o.statusline .. " [%n]"                                  -- Buffer number
o.statusline = o.statusline .. " %y"                                    -- File type
o.statusline = o.statusline .. " %m%r%w"                                -- Modified? Read-only? Preview?
o.statusline = o.statusline .. "%="                                     --
o.statusline = o.statusline .. " [(%l:%v)/%L]"                          -- Row:col number/total lines (%)
o.statusline = o.statusline .. " [%{''.(&fenc!=''?&fenc:&enc).''}"      -- File encoding
o.statusline = o.statusline .. "%{(&bomb?\", BOM\":\"\")}"              -- Byte order mark
o.statusline = o.statusline .. "%{(&paste?\", PASTE\":\"\")}]"          -- Paste mode
o.statusline = o.statusline .. " [%{&spelllang}]"                       -- Language
o.statusline = o.statusline .. " [%{mode()}]"                           -- Mode

o.showmode = false                                                      -- This is covered by the statusline now


-- TITLEBAR

cmd "set t_ts=k"
cmd "set t_fs=\\"

do
  local timerid = 0
  local group = api.nvim_create_augroup("titlebar_naming", { clear = true })
  local doTimer = function() end
  doTimer = function()
    if timerid > 0 then fn.timer_stop(timerid) end
    timerid = 0
    if o.buftype == "terminal" then
      timerid = fn.timer_start(5000, doTimer, { ["repeat"] = -1 })
    end
  end
  api.nvim_create_autocmd("VimLeave", { command = "set t_ts=k\\", group = group })
  api.nvim_create_autocmd("BufEnter", {
    callback = function()
      o.title = true
      if o.buftype == "terminal" then
        o.titlestring = b.term_title
      else
        local file_path = fn.expand("%:p")
        if file_path == "" or o.buftype == "help" then
          o.titlestring = fn.getcwd()
        else
          o.titlestring = file_path
        end
      end
      doTimer()
    end,
    group = group
  })
  api.nvim_create_autocmd("BufLeave", {
    callback = function()
      if timerid > 0 then fn.timer_stop(timerid) end
    end,
    group = group
  })
end

-- Restore last cursor position
api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if fn.line("'\"") > 1 and fn.line("'\"") <= fn.line("$") then
      api.nvim_win_set_cursor(0, api.nvim_buf_get_mark(0, '"'))
    end
  end,
  group = api.nvim_create_augroup("cursor_position", { clear = true })
})


keymap.set("n", "yoS", fn["toggle#inccommand"], { desc = "Cycle through inccommand options" })


keymap.set("n", "da<Space>", mkFn(cursorPreserveCmd, "%s/ \\+$//e"), { desc = "Delete all trailing whitespace" })


keymap.set("i", "jj", "<ESC>", { desc = "Return to normal mode via home row" })
keymap.set("i", "jkj", "j<ESC>", { desc = "Return to normal mode via home row after typing j" })


keymap.set("n", "<BS>", "<C-^>", { desc = "Use backspace to flip between files" })

keymap.set("n", "Q", "@@", { desc = "Repeat last macro (use gQ to go into ex mode" })

keymap.set({ "n", "v" }, "v", "<C-V>", { desc = "Toggle visual block mode" })
keymap.set({ "n", "v" }, "<C-V>", "v", { desc = "Toggle visual mode" })

keymap.set("n", "j", function() return ((v.count > 5) and ("m'" .. v.count .. "j") or "j") end,
  { expr = true, desc = "Save big down movement to jumplist" })
keymap.set("n", "k", function() return ((v.count > 5) and ("m'" .. v.count .. "k") or "k") end,
  { expr = true, desc = "Save big up movement to jumplist" })

keymap.set("c", "%%", function() return fn.fnameescape(fn.expand('%:h') .. '/') end,
  { expr = true, desc = "Expand current file's directory" })
keymap.set("c", "%p", function() return fn.fnameescape(fn.expand('%:p')) end,
  { expr = true, desc = "Expand current file's full path" })
keymap.set("c", "%r", function() return fn.fnameescape(fn.expand('%')) end,
  { expr = true, desc = "Expand current file's relative path" })

keymap.set("n", "<Leader>w", fn["buffer#update"], { desc = "Update buffer" })
keymap.set("n", "<Leader>q", fn["buffer#quit"], { desc = "Quit with warning" })
keymap.set("n", "<Leader><Leader>q", fn["buffer#update_and_quit"], { desc = "Update and quit" })

keymap.set("n", "<Leader>s", ":%s//g<LEFT><LEFT>", { desc = "Global substituion of whole buffer" })
keymap.set("v", "<Leader>s", ":s//g<LEFT><LEFT>", { desc = "Global substituion of selection" })
keymap.set("n", "<Leader>S", ":%S//g<LEFT><LEFT>", { desc = "Global Substituion of whole buffer" })
keymap.set("v", "<Leader>S", ":S//g<LEFT><LEFT>", { desc = "Global Substituion of selection" })

keymap.set("n", "<q", function() for _ = 1, v.count1 do cmd.colder() end end, { desc = "Go to older error list" })
keymap.set("n", "<Q", function() while true do cmd.silent("colder") end end, { desc = "Go to oldest error list" })
keymap.set("n", ">q", function() for _ = 1, v.count1 do cmd.cnewer() end end, { desc = "Go to newer error list" })
keymap.set("n", ">Q", function() while true do cmd.silent("cnewer") end end, { desc = "Go to newest error list" })

keymap.set("n", "<l", function() for _ = 1, v.count1 do cmd.lolder() end end, { desc = "Go to older location list" })
keymap.set("n", "<L", function() while true do cmd.silent("lolder") end end, { desc = "Go to oldest location list" })
keymap.set("n", ">l", function() for _ = 1, v.count1 do cmd.lnewer() end end, { desc = "Go to newer location list" })
keymap.set("n", ">L", function() while true do cmd.silent("lnewer") end end, { desc = "Go to newest location list" })

keymap.set("i", "<C-c>", "<ESC>", { desc = "Ensure InsertLeave is triggered with <C-c>" })

-- Overrides builtin gh (select mode), but I never use that
keymap.set("n", "gh", "ciw<C-r>=printf('0x%x', <C-r>\")<CR><Esc>", { silent = true, desc = "Convert bases" })

keymap.set("n", "<Leader>gg", ":Git<Space>", { desc = "Make arbitrary Git command" })
keymap.set("n", "<Leader>ga", cmd.Gwrite, { desc = "Stage changes in Git" })
keymap.set("n", "<Leader>gs", cmd.Git, { desc = "Git status" })

keymap.set("n", "<Leader>gps", mkFn(cmd.Git, { "push", bang = true }), { desc = "Git push" })
keymap.set("n", "<Leader>gpf", mkFn(cmd.Git, { "push --force", bang = true }), { desc = "Git force push" })
keymap.set("n", "<Leader>gpl", mkFn(cmd.Git, "pull"), { desc = "Git pull" })
keymap.set("n", "<Leader>gco", mkFn(cmd.Git, "commit"), { desc = "Git commit" })
keymap.set("n", "<Leader>gca", mkFn(cmd.Git, "commit --amend"), { desc = "Amend git commit" })
keymap.set("n", "<Leader>gcA", mkFn(cmd.Git, "commit --amend --no-edit"), { desc = "Amend git commit without edit" })
keymap.set("n", "<Leader>gre", function() cmd.Git("rebase -i HEAD~" .. v.count1) end, { desc = "Rebase git" })

keymap.set("n", "<Leader>gi", mkFn(cmd.CocList, "gitignore"), { desc = "Coc list: gitignore" })
keymap.set("n", "<Leader>ge", mkFn(cmd.CocList, "gstatus"), { desc = "Coc list: git status" })
keymap.set("n", "<Leader>gE", mkFn(cmd.CocList, "gfiles"), { desc = "Coc list: git files" })
keymap.set("n", "<Leader>gC", mkFn(cmd.CocList, "commits"), { desc = "Coc list: git commits" })

keymap.set("n", "[h", "<Plug>(coc-git-prevchunk)", { desc = "Previous git chunk" })
keymap.set("n", "]h", "<Plug>(coc-git-nextchunk)", { desc = "Next git chunk" })
keymap.set("n", "<Leader>hp", "<Plug>(coc-git-chunkinfo)", { desc = "Git chunk info" })
keymap.set("n", "<Leader>ha", mkFn(cmd.CocCommand, "git.chunkStage"), { desc = "Stage git chunk" })
keymap.set("n", "<Leader>hu", mkFn(cmd.CocCommand, "git.chunkUndo"), { desc = "Unstage git chunk" })
keymap.set("n", "<Leader>cp", "<Plug>(coc-git-commit)", { desc = "Git commit" })
keymap.set({ "x", "o" }, "ih", "<Plug>(coc-git-chunk-inner)", { remap = true, desc = "Git chunk i text object" })
keymap.set({ "x", "o" }, "ah", "<Plug>(coc-git-chunk-outer)", { remap = true, desc = "Git chunk a text object" })

keymap.set({ "x", "o" }, "i,", "<Plug>(swap-textobject-i)", { remap = true, desc = "Delimited item i text object" })
keymap.set({ "x", "o" }, "a,", "<Plug>(swap-textobject-a)", { remap = true, desc = "Delimited item a text object" })

g.gitlab_api_keys = { ["gitlab.com"] = env.GITLAB_TOKEN }

keymap.set("n", "<Leader>d", mkFn(cmd.CocList, { "files", "--type=directory" }), { desc = "Coc list: directories" })
keymap.set("n", "<Leader>D", mkFn(cmd.CocList, { "files", "%:p:h", "--type=directory" }),
  { desc = "Coc list: relative directories" })
keymap.set("n", "<Leader>e", mkFn(cmd.CocList, { "files", "--type=file" }), { desc = "Coc list: files" })
keymap.set("n", "<Leader>E", mkFn(cmd.CocList, { "files", "%:p:h", "--type=file" }),
  { desc = "Coc list: relative files" })
keymap.set("n", "<Leader>h:", mkFn(cmd.CocList, "cmdhistory"), { desc = "Coc list: command history" })
keymap.set("n", "<Leader>h/", mkFn(cmd.CocList, "searchhistory"), { desc = "Coc list: search history" })
keymap.set("n", "<Leader>mr", mkFn(cmd.CocList, "mru"), { desc = "Coc list: recent files" })
keymap.set("n", "<Leader>he", mkFn(cmd.CocList, "helptags"), { desc = "Coc list: helptags" })
keymap.set("n", "<Leader>ta", mkFn(cmd.CocList, "tags"), { desc = "Coc list: tags" })
keymap.set("n", "<Leader>b", mkFn(cmd.CocList, "buffers"), { desc = "Coc list: buffers" })
keymap.set("n", "<Leader>B", mkFn(cmd.CocList, "lines"), { desc = "Coc list: lines" })

keymap.set("n", "<Leader>a", ":silent! grep<Space>", { desc = "Populate quickfix with grep" })
keymap.set("n", "<Leader>A", ":silent! grepadd<Space>", { desc = "Add to quickfix with grep" })
keymap.set("n", "<Leader><Leader>a", ":silent! lgrep<Space>", { desc = "Populate location list with grep" })
keymap.set("n", "<Leader><Leader>A", ":silent! lgrepadd<Space>", { desc = "Add to location list with grep" })

keymap.set("n", "<Leader>cu", cmd.CocUpdate, { desc = "Update Coc plugins" })

api.nvim_create_autocmd("TextYankPost", { callback = vim.hl.on_yank, desc = "Briefly highlight yanked area" })

keymap.set("n", "Y", "y$", { remap = true, desc = "Make Y work more like D, C etc. yy works same as stock Y" })

keymap.set("i", "<M-y>", '<C-o>"*y', { remap = true, desc = "(y)ank using system clipboard" })
keymap.set({ "v", "n" }, "<M-y>", '"*y', { remap = true, desc = "(y)ank using system clipboard" })
keymap.set("i", "<M-y><M-y>", '<C-o>"*yy', { remap = true, desc = "(yy)ank using system clipboard" })
keymap.set("n", "<M-y><M-y>", '"*yy', { remap = true, desc = "(yy)ank using system clipboard" })
keymap.set("i", "<M-S-y>", '<C-o>"*Y', { remap = true, desc = "(Y)ank using system clipboard" })
keymap.set("n", "<M-S-y>", '"*Y', { remap = true, desc = "(Y)ank using system clipboard" })
keymap.set({ "i", "c" }, "<M-p>", "<C-r>*", { remap = true, desc = "(p)ut using system clipboard" })
keymap.set({ "v", "n" }, "<M-p>", '"*p', { remap = true, desc = "(p) using system clipboard" })
keymap.set("t", "<M-p>", "<A-r>*", { remap = true, desc = "(p)ut using system clipboard" })
keymap.set("i", "<M-S-p>", '<C-o>"*P', { remap = true, desc = "(P)ut using system clipboard" })
keymap.set("n", "<M-S-p>", '"*P', { remap = true, desc = "(P)ut using system clipboard" })
keymap.set("n", "[<M-p>", '"*[p', { remap = true, desc = "([p)ut using system clipboard" })
keymap.set("n", "]<M-p>", '"*]p', { remap = true, desc = "(]p)ut using system clipboard" })

keymap.set("n", "<Leader>p", function() fn.setreg("+", fn.getreg("0", 1)) end,
  { remap = true, desc = "Copy last yank to system clipboard" })
keymap.set("n", "<Leader>P", function() fn.setreg("+", fn.getreg('"', 1)) end,
  { remap = true, desc = "Copy unnamed register to system clipboard" })

keymap.set("t", "<A-r>", function() return "<C-\\><C-N>" .. fn.nr2char(fn.getchar()) .. "pi" end,
  { expr = true, desc = "Insert register into terminal buffer" })

if not env.SSH_CLIENT then
  local function char_to_hex(c) return string.format("%%%02X", string.byte(c)) end

  local function urlencode(url)
    if url == nil then return end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
  end

  local open = "start"
  if fn.has("unix") then open = "xdg-open" end
  if fn.has("mac") then open = "open" end

  Search = {}
  local function makeSearch(char, name, prefix, escapeSelction)
    Search[name] = function(kind, str)
      local sel_save = o.selection
      local reg_save = fn.getreg("@", 1)
      o.selection = "inclusive"
      kind = kind or "visual"

      if str then
        fn.setreg("@", str)
      else
        cmd("normal! " .. ({ line = "'[C']y", char = "`[v`]y", block = "`[<C-v>`]y", visual = "y" })[kind])
      end

      local search_term = escapeSelction and urlencode(fn.getreg("@", 0)) or fn.getreg("@", 0)
      fn.system(open .. " '" .. prefix .. search_term .. "'")

      o.selection = sel_save
      fn.setreg("@", reg_save)
    end

    local function norm_map()
      o.opfunc = "v:lua.Search." .. name
      return "g@"
    end

    keymap.set("n", "<Leader>/" .. char, norm_map, { expr = true, desc = "Search " .. name .. " using motion" })
    keymap.set("v", "<Leader>/" .. char, Search[name], { desc = "Search " .. name .. " with selection" })
  end
  makeSearch("/", "DuckDuckGo", "https://duckduckgo.com/?q=", true)
  makeSearch("g", "Github", "https://github.com/", false)
  makeSearch("d", "Dict", "https://dictionary.reference.com/browse/", false)
  makeSearch("c", "CanIUse", "https://caniuse.com/#search=", true)
  makeSearch("w", "Wikipedia", "https://en.wikipedia.org/wiki/Special:Search?search=", true)
  makeSearch("n", "NPM", "https://www.npmjs.com/search?q=", true)
end

keymap.set("i", "<A-k>", "<C-o>K", { desc = "Show documentation" })

keymap.set("v", "<C-/>", "<Esc>/\\%V", { desc = "Search within current selection" })

api.nvim_create_user_command("Keywordprg", function(params)
  if fn.exists("*CocHasProvider") and fn.CocHasProvider("hover") then
    fn.CocAction("doHover")
  elseif o.filetype == "vim" or o.filetype == "help" then
    cmd("h " .. fn.expand('<cword>'))
  elseif o.filetype == "fish" then
    cmd("Man " .. fn.system("man -w " .. fn.expand("<cword>")))
  elseif o.filetype == "shell" or o.filetype == "sh" or o.filetype == "bash" or o.filetype == "zsh" then
    cmd("Man " .. fn.expand('<cword>'))
  elseif not env.SSH_CLIENT then
    fn.system('search ' .. params.args)
  else
    cmd("echoerr 'Don’t know what keyword program to use'")
  end
end, { nargs = "+" })
o.keywordprg = ":Keywordprg"

keymap.set("i", "<A-Tab>", fn["coc#refresh"], { expr = true, desc = "Force coc menu" })
keymap.set("i", "<Tab>", function()
  if fn["coc#pum#visible"]() > 0 then
    return fn["coc#pum#next"](1)
  else
    local c = fn.col('.') - 1
    if c < 1 or string.match(fn.getline('.'):sub(c - 1, c - 1), "%s") then
      return "<Tab>"
    else
      return fn["coc#refresh"]()
    end
  end
end, { expr = true, desc = "Overload Tab", silent = true })
keymap.set("i", "<S-Tab>", function()
  if fn["coc#pum#visible"]() > 0 then
    return fn["coc#pum#prev"](1)
  else
    return '<C-o>:call coc#start()<CR>'
  end
end, { expr = true, desc = "Overload Shift+Tab", silent = true })
keymap.set("i", "<CR>", function()
  if fn["coc#pum#visible"]() > 0 then
    return fn["coc#pum#confirm"]()
  else
    return "<CR><C-r>=coc#on_enter()<CR>"
  end
end, { expr = true, desc = "Overload Return", silent = true })

keymap.set("n", "gd", "<Plug>(coc-definition)", { remap = true, silent = true, desc = "Go to definition using Coc" })
keymap.set("n", "gy", "<Plug>(coc-type-definition)",
  { remap = true, silent = true, desc = "Go to type definition using Coc" })
keymap.set("n", "gi", "<Plug>(coc-implementation)",
  { remap = true, silent = true, desc = "Go to implementation using Coc" })
keymap.set("n", "gr", "<Plug>(coc-references)", { remap = true, silent = true, desc = "See references using Coc" })

keymap.set("n", "<Leader>r", "<Plug>(coc-rename)", { remap = true, desc = "Rename using LS" })

keymap.set("x", "<Leader>f", "<Plug>(coc-format-selected)", { remap = true, silent = true, desc = "Format selected" })
keymap.set("n", "<Leader>f", "<Plug>(coc-format)", { remap = true, silent = true, desc = "Format file" })

keymap.set("n", "<Leader><Leader>f", "<Plug>(coc-fix-current)",
  { remap = true, silent = true, desc = "Use first autofix suggestion for current line" })
keymap.set("n", "<Leader><Leader>F", function() fn.CocActionAsync("codeAction", "quickfix") end,
  { remap = true, silent = true, desc = "Show autofix options" })

do
  local group = api.nvim_create_augroup("cocnvim", { clear = true })
  api.nvim_create_autocmd("CursorHold", { callback = mkFn(fn.CocActionAsync, "highlight"), group = group })
  api.nvim_create_autocmd("User",
    { pattern = "CocJumpPlaceholder", callback = mkFn(fn.CocActionAsync, "showSignatureHelp"), group = group })
end

keymap.set({ "n", "x" }, "<Leader>;", "<Plug>(coc-codeaction-selected)",
  { remap = true, desc = "Perform codeAction on selected" })
keymap.set("n", "<Leader>;c", "<Plug>(coc-codeaction)", { remap = true, desc = "Perform codeAction on file" })
keymap.set("n", "<Leader>;;", "<Plug>(coc-codeaction-cursor)",
  { remap = true, desc = "Perform codeAction where cursor is" })
keymap.set("n", "<A-;>", "<Plug>(coc-codelens-action)", { remap = true, desc = "Perform codeLens on current line" })

keymap.set({ "x", "o" }, "if", "<Plug>(coc-funcobj-i)", { silent = true, remap = true, desc = "inside function" })
keymap.set({ "x", "o" }, "af", "<Plug>(coc-funcobj-a)", { silent = true, remap = true, desc = "around function" })
keymap.set({ "x", "o" }, "ic", "<Plug>(coc-classobj-i)", { silent = true, remap = true, desc = "inside class" })
keymap.set({ "x", "o" }, "ac", "<Plug>(coc-classobj-a)", { silent = true, remap = true, desc = "around class" })

keymap.set({ "x", "n" }, "<C-d>", "<Plug>(coc-range-select)", { silent = true, desc = "Select next selection range" })

keymap.set("i", "<C-l>", "<Plug>(coc-snippets-expand)", { remap = true, desc = "Expand snippet" })
keymap.set("v", "<C-j>", "<Plug>(coc-snippets-select)", { remap = true, desc = "Navigate snippet placeholder" })
keymap.set("i", "<C-j>", "<Plug>(coc-snippets-expand-jump)", { remap = true, desc = "Expand/jump snippet" })

keymap.set("n", "<A-f>", function()
  if fn.getwinvar('%', 'float') then
    cmd "norm <C-v><C-w>p"
  else
    fn["coc#float#jump"]()
  end
end, { desc = "Toggle floating window focus" })

keymap.set("n", "<Leader>ci", "<Plug>(coc-diagnostic-info)",
  { remap = true, desc = "Show diagnostic message of current position" })
keymap.set("n", "]d", "<Plug>(coc-diagnostic-next)", { remap = true, desc = "Jump to next diagnostic position" })
keymap.set("n", "[d", "<Plug>(coc-diagnostic-prev)", { remap = true, desc = "Jump to previous diagnostic position" })
keymap.set("n", "]D", "<Plug>(coc-diagnostic-next-error)",
  { remap = true, desc = "Jump to next d iagnostic error position" })
keymap.set("n", "[D", "<Plug>(coc-diagnostic-prev-error)",
  { remap = true, desc = "Jump to previous diagnostic error position" })

keymap.set("x", ".", ":norm .<CR>", { desc = "Repeat on each line of visual selection" })

-- FORMATTING

keymap.set("n", "yof", function()
  if g.should_autoformat == nil then g.should_autoformat = true end
  g.should_autoformat = not g.should_autoformat
  print(g.should_autoformat and "Autoformat globally" or "Do not autoformat globally")
end, { desc = "Toggle autoformatting on save globally" })
keymap.set("n", "[of", function()
  g.should_autoformat = false
  print("Do not autoformat globally")
end, { desc = "Turn off autoformatting on save globally" })
keymap.set("n", "]of", function()
  g.should_autoformat = true
  print("Autoformat globally")
end, { desc = "Turn on autoformatting on save globally" })
keymap.set("n", "yoF", function()
  if b.should_autoformat == nil then b.should_autoformat = true end
  b.should_autoformat = not b.should_autoformat
  print(b.should_autoformat and "Autoformat this buffer" or "Do not autoformat this buffer")
end, { desc = "Toggle autoformatting on save for this buffer" })
keymap.set("n", "[oF", function()
  b.should_autoformat = false
  print("Do not autoformat this buffer")
end, { desc = "Turn off autoformatting on save for this buffer" })
keymap.set("n", "]oF", function()
  b.should_autoformat = true
  print("Autoformat this buffer")
end, { desc = "Turn on autoformatting on save for this buffer" })

do
  local group = api.nvim_create_augroup("formatting", { clear = true })
  api.nvim_create_autocmd("BufWritePre", {
    desc = "Format if autoformat enabled",
    group = group,
    callback = function()
      if b.should_autoformat == false then return end
      if g.should_autoformat == nil then g.should_autoformat = true end
      if not g.should_autoformat then return end
      if not fn.exists("*CocHasProvider") or not fn.CocHasProvider("format") then return end
      print("Formatting…")
      local format_finished = false
      fn.CocActionAsync("format", function(err)
        if err == vim.NIL then
          print("Formatted")
        else
          print("Formatting error")
          print(err)
        end
        format_finished = true
      end)
      wait(2000, function() return format_finished end, 200)
      if not format_finished then print("Timed out") end
    end
  })
  api.nvim_create_autocmd("FileType", {
    desc = "Setup formatting using Coc.nvim",
    group = group,
    callback = function()
      if fn.exists("*CocHasProvider") and pcall(fn.CocHasProvider, "format") then
        opt_local.formatexpr = "CocAction('formatSelected')"
      end
    end
  })
end

-- TAGBAR

keymap.set("n", "yot", cmd.TagbarToggle, { desc = "Toggle Tagbar sidebar" })
keymap.set("n", "]ot", cmd.TagbarClose, { desc = "Hide Tagbar sidebar" })
keymap.set("n", "[ot", cmd.TagbarOpen, { desc = "Show Tagbar sidebar" })

keymap.set("n", "<Leader>]", ":tag<Space>", { desc = "Seach for tag" })

do
  local group = api.nvim_create_augroup("doc", { clear = true })
  api.nvim_create_autocmd("BufReadPost", {
    pattern = { "*.doc", "*.docx", "*.odp", "*.odt" },
    callback = mkFn(cmd.silent, { '%!pandoc', '"%"', '--to=markdown', '-o', '/dev/stdout' }),
    group = group
  })
  api.nvim_create_autocmd("BufReadPost", {
    pattern = { "*.rtf" },
    callback = mkFn(cmd.silent,
      { '%!textutil', '"%"', '-convert', 'html', '-stdout', '\\|', 'pandoc', '--from=html', '--to=markdown' }),
    group = group
  })
end

keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move window focus left" })
keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move window focus left" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move window focus down" })
keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move window focus down" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move window focus right" })
keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move window focus right" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move window focus up" })
keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move window focus up" })


keymap.set("t", ";;", "<C-\\><C-n>:", { desc = "Enter ex command" })
keymap.set("t", "jj", "<C-\\><C-n>", { desc = "Enter normal mode" })

keymap.set("t", "<A-Space>", "<C-\\><C-n><Leader>", { remap = true, desc = "Leader" })
keymap.set("n", "<A-Space>", "<Leader>", { remap = true, desc = "Leader" })

keymap.set("n", "<Leader>nj", mkFn(cmd, "rightbelow new"), { desc = "Open new buffer below" })
keymap.set("n", "<Leader>nk", mkFn(cmd, "leftabove new"), { desc = "Open new buffer above" })
keymap.set("n", "<Leader>nl", mkFn(cmd, "rightbelow vnew"), { desc = "Open new buffer to right" })
keymap.set("n", "<Leader>nh", mkFn(cmd, "leftabove vnew"), { desc = "Open new buffer to left" })
keymap.set("n", "<Leader>nn", cmd.enew, { desc = "Open new buffer in window" })
keymap.set("n", "<Leader>nN", cmd.tabnew, { desc = "Open new buffer in new tab" })

keymap.set("n", "<Leader>tj", mkFn(cmd, "botright horizontal terminal"), { desc = "Open terminal session below" })
keymap.set("n", "<Leader>tk", mkFn(cmd, "topleft horizontal terminal"), { desc = "Open terminal session above" })
keymap.set("n", "<Leader>tl", mkFn(cmd, "botright vertical terminal"), { desc = "Open terminal session to right" })
keymap.set("n", "<Leader>th", mkFn(cmd, "topleft vertical terminal"), { desc = "Open terminal session to left" })
keymap.set("n", "<Leader>tT", mkFn(cmd, "tab terminal"), { desc = "Open terminal session in new tab" })
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


do
  local group = api.nvim_create_augroup("terminal_insert", { clear = true })
  api.nvim_create_autocmd("BufEnter",
    {
      callback = function() if o.buftype == "terminal" and fn.line("$") == fn.line("w$") then cmd "startinsert" end end,
      group = group,
      desc = "Automatically enter intert mode in terminal if not scrolled back"
    })
  api.nvim_create_autocmd("TermOpen",
    {
      callback = function() if o.buftype == "terminal" then cmd "startinsert" end end,
      group = group,
      desc = "Automatically enter intert mode in terminal if not scrolled back"
    })
end

do
  local group = api.nvim_create_augroup("crosshairs", { clear = true })
  api.nvim_create_autocmd("WinEnter",
    {
      callback = function()
        opt_local.cursorline = true
        opt_local.cursorcolumn = true
      end,
      group = group,
      desc = "Highlight column and row on active window"
    })
  api.nvim_create_autocmd("WinLeave",
    {
      callback = function()
        opt_local.cursorline = false
        opt_local.cursorcolumn = false
      end,
      group = group,
      desc = "Don't highlight column and row on inactive windows"
    })
end

api.nvim_create_user_command("Stab", function(params)
  local ts = tonumber(params.fargs[1])
  if ts > 0 then
    opt_local.softtabstop = ts
    opt_local.tabstop = ts
    opt_local.shiftwidth = ts
  end
  if params.bang then
    cursorPreserveCmd("normal gg=G")
  end
end, { nargs = 1, bang = true, desc = "Quick way to change tab stops. Add bang to reformat file" })

api.nvim_create_user_command("Bd", "bp | bd<bang> #",
  { nargs = 0, bang = true, desc = "Delete buffer while preserving window splits" })

keymap.set("n", "yo<TAB>", fn["toggle#tabs"], { desc = "Toggle tabs/spaces" })
keymap.set("n", "[o<TAB>", mkFn(fn["toggle#tabs"], 1), { desc = "Use tabs" })
keymap.set("n", "]o<TAB>", mkFn(fn["toggle#tabs"], 0), { desc = "Use spaces" })

keymap.set("n", "yoq", fn["toggle#quickfixList"], { desc = "Toggle quickfix visibility" })
keymap.set("n", "[oq", mkFn(fn["toggle#quickfixList"], 1), { desc = "Show quickfix" })
keymap.set("n", "]oq", mkFn(fn["toggle#quickfixList"], 0), { desc = "Hide quickfix" })

keymap.set("n", "yol", fn["toggle#locationList"], { desc = "Toggle location list visibility" })
keymap.set("n", "[ol", mkFn(fn["toggle#locationList"], 1), { desc = "Show location list" })
keymap.set("n", "]ol", mkFn(fn["toggle#locationList"], 0), { desc = "Hide location list" })

keymap.set("n", "yo|", fn["toggle#lion"], { desc = "Toggle squeeze spaces in vim-lion" })
keymap.set("n", "[o|", mkFn(fn["toggle#lion"], 1), { desc = "Squeeze spaces in vim-lion" })
keymap.set("n", "]o|", mkFn(fn["toggle#lion"], 0), { desc = "Don't squeeze spaces in vim-lion" })


-- Avoid conflicting with matchit.vim (see https://github.com/jeetsukumaran/vim-indentwise/issues/6)
keymap.set("", "[<BS>", "<Plug>(IndentWiseBlockScopeBoundaryBegin)", { desc = "Move to beginning of block" })
keymap.set("", "]<BS>", "<Plug>(IndentWiseBlockScopeBoundaryEnd)", { desc = "Move to end of block" })

if (fn.isdirectory("/Applications/Setapp/Dash.app") or fn.isdirectory("/Applications/Dash.app")) and not env.SSH_CLIENT then
  cmd.packadd "dash.vim"
  keymap.set("n", "gK", "<Plug>DashSearch", { desc = "Search using Dash" })
end

-- FTDETECT TODO USE nathom/filetype.nvim

do
  local group = api.nvim_create_augroup("detection", { clear = true })
  api.nvim_create_autocmd({ "BufNewFile", "BufRead" },
    { pattern = "*.es6", command = "setfiletype javascript", group = group })
  api.nvim_create_autocmd({ "BufNewFile", "BufRead" },
    { pattern = "*.gitconfig", command = "setfiletype gitconfig", group = group })
  api.nvim_create_autocmd({ "BufNewFile", "BufRead" },
    { pattern = "*.snippets", command = "setfiletype snippets", group = group })
  api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.html",
    callback = function()
      if #(fn.glob(fn.getcwd() .. '/config.*')) > 0 then
        o.filetype = "gohtmltmpl"
        cmd "runtime! ftdetect/html.vim"
      end
    end,
    group = group
  })
end

-- COC CUSTOM ACTIONS

function coc_create_file(context)
  for _, file in ipairs(context.targets) do
    local filename = fn.input("Enter filename: ")
    local buffer_id = fn.bufadd(fn.fnamemodify(string.gsub(file.location.uri, "file://", ""), ":p:h") .. "/" .. filename)
    api.nvim_win_set_buf(context.winid, buffer_id)
  end
  fn["coc#list#clean_up"]()
end

cmd [[
function! Coc_create_file(context) abort
  call v:lua.coc_create_file(a:context)
endfunction
]]

function coc_populate_args(context)
  local args = "args"
  for _, file in ipairs(context.targets) do
    args = args .. " " .. string.gsub(file.location.uri, "file://", "")
  end
  cmd(args)
  fn["coc#list#clean_up"]()
end

cmd [[
function! Coc_populate_args(context) abort
  call v:lua.coc_populate_args(a:context)
endfunction
]]

function coc_delete_file(context)
  local files = ""
  for _, file in ipairs(context.targets) do
    files = files .. " " .. string.gsub(file.location.uri, "file://", "")
  end
  if fn.confirm("Delete" .. files .. "?", "&Yes\n&No", 2, "Question") == 1 then
    cmd("Remove" .. files)
  end
  fn["coc#list#clean_up"]()
end

cmd [[
function! Coc_delete_file(context) abort
  call v:lua.coc_delete_file(a:context)
endfunction
]]

-- TREESITTER

require 'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 200 * 1024 -- 200 KB
      local ok, stats = pcall(vim.loop.fs_stat, api.nvim_buf_get_name(buf))
      return ok and stats and stats.size > max_filesize
    end,
    additional_vim_regex_highlighting = false,
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<Leader>v",
      node_incremental = "<Right>",
      scope_incremental = "<Up>",
      node_decremental = "<Left>",
    },
  },

  indent = {
    enable = true,
  },

  refactor = {
    highlight_definitions = {
      enable = true,
      clear_on_cursor_move = true,
    },

    highlight_current_scope = {
      enable = true,
    },

    smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "<Leader>R", -- use this if Coc’s LS rename (<Leader>r) doesn’t work
      },
    },

    navigation = {
      enable = true,
      keymaps = {
        goto_definition = "<Leader>gd",
        list_definitions = "<Leader>gD",
        list_definitions_toc = "gO",
        goto_next_usage = "<a-*>",
        goto_previous_usage = "<a-#>",
      },
    },

  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        -- TODO work out which textobj plugins this can replace
        ["aF"] = { query = "@function.outer", desc = "Select around function" },
        ["iF"] = { query = "@function.inner", desc = "Select inside function" },
        ["aC"] = { query = "@comment.outer", desc = "Select around comment" },
        ["iC"] = { query = "@comment.inner", desc = "Select inside comment" },
      },
      selection_modes = {
        ['@parameter.outer'] = 'v',
        ['@function.outer'] = 'V',
        ['@class.outer'] = 'V',
      },
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      include_surrounding_whitespace = function(query_string, selection_mode)
        if selection_mode == 'v' or selection_mode == 'V' then
          return true
        end
        return false
      end,
    },
    move = {
      -- TODO set up (https://github.com/nvim-treesitter/nvim-treesitter-textobjects#text-objects-move)
      enable = false,
    },
    lsp_interop = {
      -- TODO set up (https://github.com/nvim-treesitter/nvim-treesitter-textobjects#textobjects-lsp-interop)
      enable = true,
      border = 'none',
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>K"] = "@function.outer",
      },
    },
  },
}
require 'treesitter-context'.setup {
  enable = true,
  max_lines = 0,
  min_window_height = 20,
  line_numbers = true,
  multiline_threshold = 10,
  trim_scope = 'outer',
  mode = 'cursor',
  separator = nil,
  zindex = 20,
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}


opt.foldmethod = 'expr'
opt.foldexpr = 'nvim_treesitter#foldexpr()'
opt.foldenable = false

require('claude-code').setup()
