if vim.env.NVIM_SKIP_PLUGIN_BOOTSTRAP == "1" then
  return
end

local function gh(repo, opts)
  if type(opts) == "string" then
    opts = { name = opts }
  end

  return vim.tbl_extend("force", {
    source = repo,
  }, opts or {})
end

local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"

vim.opt.rtp:append(path_package)

if not vim.uv.fs_stat(mini_path) then
  vim.fn.mkdir(path_package .. "/pack/deps/start", "p")

  local clone = vim.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/nvim-mini/mini.nvim",
    mini_path,
  }):wait()

  if clone.code ~= 0 then
    error("Failed to bootstrap mini.nvim:\n" .. (clone.stderr or clone.stdout or ""))
  end
end

vim.opt.rtp:prepend(mini_path)

require("mini.deps").setup({
  path = {
    package = path_package,
  },
})

local add = MiniDeps.add

local function ts_update()
  pcall(vim.cmd, "TSUpdateSync")
end

local specs = {
  gh("nvim-mini/mini.nvim", { name = "mini.nvim", checkout = "stable" }),
  gh("nvim-lua/plenary.nvim"),
  gh("catppuccin/nvim", { name = "catppuccin" }),
  gh("nvim-telescope/telescope.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  gh("stevearc/conform.nvim"),
  gh("neovim/nvim-lspconfig"),
  gh("Saghen/blink.cmp", { checkout = "v1.9.1" }),
  gh("nvim-treesitter/nvim-treesitter", {
    hooks = {
      post_install = ts_update,
      post_checkout = ts_update,
    },
  }),
  gh("nvim-treesitter/nvim-treesitter-context"),
  gh("nvim-treesitter/nvim-treesitter-textobjects"),
  gh("greggh/claude-code.nvim"),
  gh("johnseth97/codex.nvim"),
  gh("tpope/vim-unimpaired"),
  gh("fcpg/vim-kickfix"),
  gh("tpope/vim-fugitive"),
  gh("tpope/vim-repeat"),
  gh("junegunn/gv.vim"),
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
}

if vim.fn.has("mac") == 1 and (vim.fn.isdirectory("/Applications/Setapp/Dash.app") == 1 or vim.fn.isdirectory("/Applications/Dash.app") == 1) then
  table.insert(specs, gh("rizzatti/dash.vim"))
end

for _, spec in ipairs(specs) do
  add(spec)
end
