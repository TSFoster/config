local util = require("config.util")

local mini_notify = util.safe_require("mini.notify")
if mini_notify then
  mini_notify.setup()
  vim.notify = mini_notify.make_notify()
end

local catppuccin = util.safe_require("catppuccin")
if catppuccin then
  catppuccin.setup({
    flavour = "mocha",
  })
end

pcall(vim.cmd.colorscheme, "catppuccin")

local mini_animate = util.safe_require("mini.animate")
if mini_animate then
  mini_animate.setup({
    cursor = { enable = false },
    scroll = { timing = mini_animate.gen_timing.linear({ duration = 100, unit = "total" }) },
    resize = { timing = mini_animate.gen_timing.linear({ duration = 100, unit = "total" }) },
    open = { timing = mini_animate.gen_timing.linear({ duration = 100, unit = "total" }) },
    close = { timing = mini_animate.gen_timing.linear({ duration = 100, unit = "total" }) },
  })
end

local mini = util.safe_require("mini.ai")
if mini then
  local function nonblank_span(line)
    local start_col = line:find("%S")
    if not start_col then
      return 1, math.max(#line, 1)
    end

    local end_col = line:match(".*()%S")
    return start_col, end_col
  end

  local function line_textobject(ai_type)
    local line_num = vim.fn.line(".")
    local line = vim.fn.getline(line_num)
    local from_col, to_col = 1, math.max(#line, 1)

    if ai_type == "i" then
      from_col, to_col = nonblank_span(line)
    end

    return {
      from = { line = line_num, col = from_col },
      to = { line = line_num, col = to_col },
      vis_mode = "V",
    }
  end

  local function file_textobject(ai_type)
    local line_count = vim.api.nvim_buf_line_count(0)
    local from_line, to_line = 1, line_count
    local from_col, to_col = 1, math.max(#vim.fn.getline(line_count), 1)

    if ai_type == "i" then
      while from_line < to_line and vim.fn.getline(from_line):find("^%s*$") do
        from_line = from_line + 1
      end
      while to_line > from_line and vim.fn.getline(to_line):find("^%s*$") do
        to_line = to_line - 1
      end

      from_col = select(1, nonblank_span(vim.fn.getline(from_line)))
      to_col = select(2, nonblank_span(vim.fn.getline(to_line)))
    end

    return {
      from = { line = from_line, col = from_col },
      to = { line = to_line, col = to_col },
      vis_mode = "V",
    }
  end

  mini.setup({
    n_lines = 500,
    custom_textobjects = {
      L = line_textobject,
      e = file_textobject,
    },
  })
end

local mini_basics = util.safe_require("mini.basics")
if mini_basics then
  mini_basics.setup({
    options = {
      basic = true,
      extra_ui = true,
      win_borders = "single",
    },
    mappings = {
      basic = true,
      option_toggle_prefix = "yo",
      windows = false,
      move_with_alt = false,
    },
    autocommands = {
      basic = true,
      relnum_in_visual_mode = false,
    },
    silent = true,
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

local mini_bracketed = util.safe_require("mini.bracketed")
if mini_bracketed then
  mini_bracketed.setup()
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
      { mode = "n", keys = "yo" },
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
      { mode = "n", keys = "<Leader>m", desc = "+mini" },
      { mode = "n", keys = "<Leader>n", desc = "+new" },
      { mode = "n", keys = "<Leader>t", desc = "+terminal/tags/tools" },
      { mode = "n", keys = "<Leader>/", desc = "+search web" },
      { mode = "n", keys = "<Leader><Leader>", desc = "+secondary" },
      { mode = "n", keys = "yo", desc = "+toggle options" },
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

local mini_cmdline = util.safe_require("mini.cmdline")
if mini_cmdline then
  mini_cmdline.setup({
    autocomplete = {
      enable = false,
    },
  })
end

local mini_comment = util.safe_require("mini.comment")
if mini_comment then
  mini_comment.setup()
end

local mini_icons = util.safe_require("mini.icons")
if mini_icons then
  mini_icons.setup()
end

local mini_indentscope = util.safe_require("mini.indentscope")
if mini_indentscope then
  mini_indentscope.setup({
    draw = {
      delay = 0,
      animation = mini_indentscope.gen_animation.none(),
    },
    symbol = "│",
  })
end

local mini_jump = util.safe_require("mini.jump")
if mini_jump then
  mini_jump.setup()
end

local mini_jump2d = util.safe_require("mini.jump2d")
if mini_jump2d then
  mini_jump2d.setup({
    view = {
      dim = true,
      n_steps_ahead = 2,
    },
  })
end

local mini_move = util.safe_require("mini.move")
if mini_move then
  mini_move.setup({
    mappings = {
      left = "<S-Left>",
      right = "<S-Right>",
      down = "<S-Down>",
      up = "<S-Up>",
      line_left = "<S-Left>",
      line_right = "<S-Right>",
      line_down = "<S-Down>",
      line_up = "<S-Up>",
    },
  })
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

local mini_sessions = util.safe_require("mini.sessions")
if mini_sessions then
  mini_sessions.setup({
    autoread = false,
    autowrite = true,
  })
end

local mini_snippets = util.safe_require("mini.snippets")
if mini_snippets then
  local gen_loader = mini_snippets.gen_loader

  mini_snippets.setup({
    snippets = {
      gen_loader.from_lang({ silent = true }),
      gen_loader.from_file(".vscode/project.code-snippets", { silent = true }),
    },
    mappings = {
      expand = "<C-l>",
      jump_next = "<C-l>",
      jump_prev = "<C-h>",
      stop = "<C-c>",
    },
  })
end

local mini_surround = util.safe_require("mini.surround")
if mini_surround then
  mini_surround.setup({
    mappings = {
      add = "sa",
      delete = "sd",
      find = "sf",
      find_left = "sF",
      highlight = "sh",
      replace = "sc",

      suffix_last = "l",
      suffix_next = "n",
    },
  })
end

local mini_trailspace = util.safe_require("mini.trailspace")
if mini_trailspace then
  mini_trailspace.setup()
end

local mini_visits = util.safe_require("mini.visits")
if mini_visits then
  mini_visits.setup({
    store = {
      autowrite = true,
    },
  })
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

local fterm = util.safe_require("FTerm")
if fterm then
  fterm.setup({})
end

local ansi = util.safe_require("ansi")
if ansi then
  ansi.setup({
    auto_enable = true,
    filetypes = { "log", "ansi", "pager", "man" },
    theme = "catppuccin",
  })
end
