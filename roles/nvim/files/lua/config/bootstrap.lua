if vim.env.NVIM_SKIP_PLUGIN_BOOTSTRAP == "1" then
  return
end

local function gh(repo, opts)
  if type(opts) == "string" then
    opts = { name = opts }
  end

  return vim.tbl_extend("force", {
    src = "https://github.com/" .. repo,
  }, opts or {})
end

local path_package = vim.fn.stdpath("data") .. "/site"

if not vim.tbl_contains(vim.opt.packpath:get(), path_package) then
  vim.opt.packpath:append(path_package)
end

local function ts_update()
  pcall(vim.cmd, "TSUpdateSync")
end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local spec = ev.data and ev.data.spec
    if not spec or spec.name ~= "nvim-treesitter" then
      return
    end

    if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
      return
    end

    vim.cmd.packadd("nvim-treesitter")
    ts_update()
  end,
})

local specs = {
  gh("nvim-mini/mini.nvim", { name = "mini.nvim", version = "stable" }),
  gh("rafamadriz/friendly-snippets"),
  gh("nvim-lua/plenary.nvim"),
  gh("catppuccin/nvim", { name = "catppuccin" }),
  gh("nvim-telescope/telescope.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  gh("stevearc/conform.nvim"),
  gh("neovim/nvim-lspconfig"),
  gh("Saghen/blink.cmp", { version = "v1" }),
  gh("nvim-treesitter/nvim-treesitter"),
  gh("nvim-treesitter/nvim-treesitter-context"),
  gh("nvim-treesitter/nvim-treesitter-textobjects"),
  gh("numToStr/FTerm.nvim"),
  gh("fcpg/vim-kickfix"),
  gh("tpope/vim-fugitive"),
  gh("tpope/vim-repeat"),
  gh("mbbill/undotree"),
  gh("mogelbrod/vim-jsonpath"),
  gh("shumphrey/fugitive-gitlab.vim"),
  gh("tpope/vim-rhubarb"),
  gh("tpope/vim-eunuch"),
  gh("tpope/vim-abolish"),
  gh("bkad/CamelCaseMotion"),
  gh("tpope/vim-speeddating"),
  gh("tpope/vim-characterize"),
  gh("jeetsukumaran/vim-indentwise"),
  gh("machakann/vim-swap"),
  gh("AndrewRadev/switch.vim"),
  gh("tpope/vim-projectionist"),
  gh("justinmk/vim-dirvish"),
  gh("kristijanhusak/vim-dirvish-git"),
  gh("bounceme/remote-viewer"),
  gh("tpope/vim-dispatch"),
  gh("TSFoster/vim-dispatch-neovim"),
  gh("tpope/vim-dotenv"),
  gh("amadeus/vim-convert-color-to"),
  gh("ap/vim-css-color"),
  gh("chrisbra/csv.vim"),
  gh("0xferrous/ansi.nvim"),
  gh("obsidian-nvim/obsidian.nvim"),
  gh("olimorris/codecompanion.nvim"),
}

vim.pack.add(specs, {
  confirm = false,
})
