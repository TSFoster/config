local opt = vim.opt
local g = vim.g

opt.backupdir:remove(".")
opt.breakindent = true
opt.showbreak = "... "
opt.cmdheight = 2
opt.expandtab = true
opt.fixendofline = false
opt.formatprg = "par rqw80"
opt.hidden = true
opt.ignorecase = true
opt.smartcase = true
opt.lazyredraw = true
opt.list = true
opt.listchars = { tab = "▸ ", trail = "·" }
opt.path:append("**")
opt.relativenumber = true
opt.number = true
opt.scrolloff = 5
opt.shortmess:append("c")
opt.spelllang = "en_gb"
opt.splitbelow = true
opt.splitright = true
opt.undofile = true
opt.undolevels = 1000
opt.undoreload = 1000
opt.updatetime = 300
opt.shada = "'1000,f1,<500"
opt.wildignorecase = true
opt.wildmode = { "list", "full" }
opt.inccommand = "nosplit"
opt.nrformats = { "bin", "hex", "unsigned", "blank" }
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false
opt.showmode = false

g.mapleader = " "

g.python3_host_prog = "~/.asdf/shims/python3"
g.node_host_prog = "~/.asdf/installs/nodejs/22.2.0/bin/neovim-node-host"
g.ruby_host_prog = "~/.asdf/shims/neovim-ruby-host"
g.loaded_perl_provider = 0

g.loaded_netrwPlugin = 1

g.undotree_WindowLayout = 2
g.undotree_ShortIndicators = 1
g.undotree_SetFocusWhenToggle = 1

g.camelcasemotion_key = "\\"
g.kickfix_zebra = 0
g.dispatch_neovim_new_cmd = "vnew"
g.switch_mapping = "g."
g.switch_reverse_mapping = "g,"
g.gitlab_api_keys = { ["gitlab.com"] = vim.env.GITLAB_TOKEN }

g.projectionist_heuristics = {
  ["elm.json"] = {
    ["*.elm"] = {
      repl = "elm repl",
    },
  },
}
