require("vim._core.ui2").enable({})

local opt = vim.opt
local g = vim.g

opt.backupdir:remove(".")
opt.showbreak = "... "
opt.cmdheight = 0
opt.conceallevel = 2
opt.expandtab = true
opt.fixendofline = false
opt.formatprg = "par rqw80"
opt.hidden = true
opt.lazyredraw = true
opt.path:append("**")
opt.relativenumber = true
opt.scrolloff = 5
opt.spelllang = "en_gb"
opt.undolevels = 1000
opt.undoreload = 1000
opt.updatetime = 300
opt.shada = "'1000,f1,<500"
opt.wildignorecase = true
opt.wildmode = { "list", "full" }
opt.wildoptions = "pum"
opt.inccommand = "nosplit"
opt.nrformats = { "bin", "hex", "unsigned", "blank" }
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false

vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
    hbs = "handlebars",
    mdx = "markdown.mdx",
  },
  filename = {
    [".ansible-lint"] = "yaml",
    ["go.work"] = "gowork",
  },
  pattern = {
    [".*/%.gitlab%-ci%.yaml"] = "yaml.gitlab",
    [".*/%.gitlab%-ci%.yml"] = "yaml.gitlab",
    [".*/docker%-compose%.yaml"] = "yaml.docker-compose",
    [".*/docker%-compose%.yml"] = "yaml.docker-compose",
    [".*/compose%.yaml"] = "yaml.docker-compose",
    [".*/compose%.yml"] = "yaml.docker-compose",
    [".*/templates/.*%.blade%.php"] = "blade",
    [".*/playbooks/.*%.yaml"] = "yaml.ansible",
    [".*/playbooks/.*%.yml"] = "yaml.ansible",
    [".*/roles/[^/]+/tasks/.*%.yaml"] = "yaml.ansible",
    [".*/roles/[^/]+/tasks/.*%.yml"] = "yaml.ansible",
    [".*/roles/[^/]+/handlers/.*%.yaml"] = "yaml.ansible",
    [".*/roles/[^/]+/handlers/.*%.yml"] = "yaml.ansible",
    [".*/roles/[^/]+/defaults/.*%.yaml"] = "yaml.ansible",
    [".*/roles/[^/]+/defaults/.*%.yml"] = "yaml.ansible",
    [".*/roles/[^/]+/vars/.*%.yaml"] = "yaml.ansible",
    [".*/roles/[^/]+/vars/.*%.yml"] = "yaml.ansible",
    [".*/ansible/.*%.yaml"] = "yaml.ansible",
    [".*/ansible/.*%.yml"] = "yaml.ansible",
    [".*/charts/[^/]+/values[^/]*%.yaml"] = "yaml.helm-values",
    [".*/charts/[^/]+/values[^/]*%.yml"] = "yaml.helm-values",
    [".*/helm/[^/]+/values[^/]*%.yaml"] = "yaml.helm-values",
    [".*/helm/[^/]+/values[^/]*%.yml"] = "yaml.helm-values",
  },
})

g.python3_host_prog = vim.fn.stdpath("config") .. "/bin/asdf-python3-host"
g.node_host_prog = vim.fn.stdpath("config") .. "/bin/asdf-node-host"
g.ruby_host_prog = vim.fn.stdpath("config") .. "/bin/asdf-ruby-host"
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
