local util = require("config.util")

pcall(vim.cmd.colorscheme, "catppuccin")

local mini = util.safe_require("mini.ai")
if mini then
  mini.setup({
    n_lines = 500,
  })
end

local mini_align = util.safe_require("mini.align")
if mini_align then
  mini_align.setup({
    mappings = {
      start = "g|",
      start_with_preview = "gA",
    },
  })
end

local mini_bufremove = util.safe_require("mini.bufremove")
if mini_bufremove then
  mini_bufremove.setup({
    silent = true,
  })
end

local mini_clue = util.safe_require("mini.clue")
if mini_clue then
  mini_clue.setup({
    triggers = {
      { mode = "n", keys = "<Leader>" },
      { mode = "x", keys = "<Leader>" },
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },
      { mode = "i", keys = "<C-x>" },
      { mode = "n", keys = "g" },
      { mode = "x", keys = "g" },
      { mode = "n", keys = "'" },
      { mode = "x", keys = "'" },
      { mode = "n", keys = "`" },
      { mode = "x", keys = "`" },
      { mode = "n", keys = '"' },
      { mode = "x", keys = '"' },
      { mode = "i", keys = "<C-r>" },
      { mode = "c", keys = "<C-r>" },
      { mode = "n", keys = "<C-w>" },
      { mode = "n", keys = "z" },
      { mode = "x", keys = "z" },
    },
    clues = {
      { mode = "n", keys = "<Leader>g", desc = "+git" },
      { mode = "n", keys = "<Leader>h", desc = "+history/help/hunks" },
      { mode = "n", keys = "<Leader>n", desc = "+new" },
      { mode = "n", keys = "<Leader>t", desc = "+terminal/tags/tools" },
      { mode = "n", keys = "<Leader>/", desc = "+search web" },
      { mode = "n", keys = "<Leader><Leader>", desc = "+secondary" },
      mini_clue.gen_clues.square_brackets(),
      mini_clue.gen_clues.builtin_completion(),
      mini_clue.gen_clues.g(),
      mini_clue.gen_clues.marks(),
      mini_clue.gen_clues.registers(),
      mini_clue.gen_clues.windows(),
      mini_clue.gen_clues.z(),
    },
    window = {
      delay = 250,
    },
  })
end

local mini_comment = util.safe_require("mini.comment")
if mini_comment then
  mini_comment.setup()
end

local mini_operators = util.safe_require("mini.operators")
if mini_operators then
  mini_operators.setup({
    evaluate = { prefix = "" },
    exchange = { prefix = "" },
    multiply = { prefix = "" },
    replace = { prefix = "" },
    sort = { prefix = "" },
  })

  mini_operators.make_mappings("sort", {
    textobject = "go",
    line = "gO",
    selection = "go",
  })
end

local mini_splitjoin = util.safe_require("mini.splitjoin")
if mini_splitjoin then
  mini_splitjoin.setup()
end

local mini_statusline = util.safe_require("mini.statusline")
if mini_statusline then
  mini_statusline.setup({
    use_icons = true,
  })
end

local mini_surround = util.safe_require("mini.surround")
if mini_surround then
  mini_surround.setup()
end

local gitsigns = util.safe_require("gitsigns")
if gitsigns then
  gitsigns.setup({
    current_line_blame = false,
    on_attach = function(buffer)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
      end

      map("n", "]h", gitsigns.next_hunk, "Next git hunk")
      map("n", "[h", gitsigns.prev_hunk, "Previous git hunk")
      map("n", "<Leader>hp", gitsigns.preview_hunk, "Preview git hunk")
      map("n", "<Leader>ha", gitsigns.stage_hunk, "Stage git hunk")
      map("n", "<Leader>hu", gitsigns.undo_stage_hunk, "Undo staged git hunk")
      map({ "o", "x" }, "ih", gitsigns.select_hunk, "Git hunk text object")
      map({ "o", "x" }, "ah", gitsigns.select_hunk, "Git hunk text object")
    end,
  })
end

local telescope = util.safe_require("telescope")
if telescope then
  telescope.setup({
    defaults = {
      path_display = { "truncate" },
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
  })
end

local treesitter = util.safe_require("nvim-treesitter.configs")
if treesitter then
  treesitter.setup({
    highlight = {
      enable = true,
      disable = function(_, buffer)
        local max_filesize = 200 * 1024
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buffer))
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
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["aF"] = { query = "@function.outer", desc = "Select around function" },
          ["iF"] = { query = "@function.inner", desc = "Select inside function" },
          ["aC"] = { query = "@comment.outer", desc = "Select around comment" },
          ["iC"] = { query = "@comment.inner", desc = "Select inside comment" },
          ["aA"] = { query = "@attribute.outer", desc = "Select around attribute" },
          ["iA"] = { query = "@attribute.inner", desc = "Select inside attribute" },
        },
        selection_modes = {
          ["@parameter.outer"] = "v",
          ["@function.outer"] = "V",
          ["@class.outer"] = "V",
        },
        include_surrounding_whitespace = function(_, selection_mode)
          return selection_mode == "v" or selection_mode == "V"
        end,
      },
      lsp_interop = {
        enable = true,
        border = "none",
        floating_preview_opts = {},
        peek_definition_code = {
          ["<Leader>K"] = "@function.outer",
        },
      },
    },
  })
end

local treesitter_context = util.safe_require("treesitter-context")
if treesitter_context then
  treesitter_context.setup({
    enable = true,
    max_lines = 0,
    min_window_height = 20,
    line_numbers = true,
    multiline_threshold = 10,
    trim_scope = "outer",
    mode = "cursor",
    separator = nil,
    zindex = 20,
  })
end

local claude = util.safe_require("claude-code")
if claude then
  claude.setup({
    refresh = {
      enable = false,
    },
  })
end
