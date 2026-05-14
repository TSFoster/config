local util = require("config.util")

local M = {}

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = false,
  float = {
    border = "rounded",
    source = "if_many",
  },
})

vim.fn.sign_define("DiagnosticSignError", { text = ">>", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "⚠ ", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "» ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "· ", texthl = "DiagnosticSignHint" })

local blink = util.safe_require("blink.cmp")
if blink then
  blink.setup({
    keymap = {
      preset = "default",
      ["<A-Tab>"] = { "show", "show_documentation", "hide_documentation" },
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      trigger = {
        show_on_keyword = true,
        show_on_trigger_character = true,
      },
      menu = {
        auto_show = true,
        auto_show_delay_ms = 0,
      },
      documentation = {
        auto_show = true,
      },
    },
    sources = {
      default = { "lsp", "path", "buffer" },
    },
    signature = {
      enabled = true,
    },
  })

  vim.lsp.config("*", {
    capabilities = blink.get_lsp_capabilities(),
  })
end

local conform = util.safe_require("conform")
if conform then
  conform.setup({
    notify_on_error = true,
    formatters_by_ft = {
      css = { "prettierd", "prettier" },
      gohtmltmpl = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      javascript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      lua = { "stylua" },
      markdown = { "prettierd", "prettier" },
      scss = { "prettierd", "prettier" },
      sh = { "shfmt" },
      typescript = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
    },
    format_on_save = function(buffer)
      if vim.b[buffer].should_autoformat == false then
        return
      end

      if vim.g.should_autoformat == nil then
        vim.g.should_autoformat = true
      end

      if not vim.g.should_autoformat then
        return
      end

      return {
        timeout_ms = 2000,
        lsp_format = "fallback",
      }
    end,
  })

  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
end

function M.format_buffer(range)
  local conform_module = util.safe_require("conform")
  if conform_module then
    conform_module.format({
      async = false,
      lsp_format = "fallback",
      range = range,
    })
    return
  end

  vim.lsp.buf.format({
    async = false,
    range = range,
  })
end

local function supports(method, buffer)
  return #vim.lsp.get_clients({ bufnr = buffer, method = method }) > 0
end

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
      },
    },
  },
})

vim.lsp.config("html", {
  filetypes = { "html", "handlebars", "htmldjango", "blade", "gohtmltmpl" },
})

vim.lsp.config("emmet_language_server", {
  filetypes = { "css", "eruby", "gohtmltmpl", "html", "javascriptreact", "less", "sass", "scss", "typescriptreact" },
})

vim.lsp.config("tailwindcss", {
  filetypes = {
    "css",
    "gohtmltmpl",
    "html",
    "javascript",
    "javascriptreact",
    "sass",
    "scss",
    "typescript",
    "typescriptreact",
    "blade",
  },
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      format = {
        enable = true,
        singleQuote = false,
        bracketSpacing = true,
        proseWrap = "preserve",
        printWidth = 80,
      },
      schemas = {
        ["http://json.schemastore.org/ansible-stable-2.9"] = "/(playbooks|roles|tasks|handlers|defaults|vars|ansible)/*.(yml|yaml)",
      },
    },
  },
})

vim.lsp.config("efm", {
  cmd = { "efm-langserver" },
  filetypes = { "vim", "eruby", "markdown" },
})

local server_commands = {
  ansiblels = "ansible-language-server",
  bashls = "bash-language-server",
  cssls = "vscode-css-language-server",
  denols = "deno",
  dockerls = "docker-langserver",
  efm = "efm-langserver",
  emmet_language_server = "emmet-language-server",
  eslint = "vscode-eslint-language-server",
  gopls = "gopls",
  html = "vscode-html-language-server",
  jsonls = "vscode-json-language-server",
  lua_ls = "lua-language-server",
  marksman = "marksman",
  pyright = "pyright-langserver",
  rust_analyzer = "rust-analyzer",
  solargraph = "solargraph",
  tailwindcss = "tailwindcss-language-server",
  ts_ls = "typescript-language-server",
  yamlls = "yaml-language-server",
}

for server, executable in pairs(server_commands) do
  if util.has_executable(executable) then
    pcall(vim.lsp.enable, server)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local buffer = event.buf

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gr", vim.lsp.buf.references, "List references")
    map("n", "<Leader>r", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "x" }, "<Leader>;", vim.lsp.buf.code_action, "Code action")
    map("n", "<Leader>;c", vim.lsp.buf.code_action, "Code action")
    map("n", "<Leader>;;", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "quickfix", "refactor", "source" },
        },
      })
    end, "Focused code action")
    map("n", "<A-;>", vim.lsp.codelens.run, "Run code lens")
    map("n", "<Leader>ci", vim.diagnostic.open_float, "Show diagnostic at cursor")
    map("i", "<A-k>", vim.lsp.buf.signature_help, "Signature help")

    if supports("textDocument/documentHighlight", buffer) then
      local group = vim.api.nvim_create_augroup("lsp_highlight_" .. buffer, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = buffer,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
        buffer = buffer,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })
    end

    if supports("textDocument/codeLens", buffer) then
      vim.lsp.codelens.enable(true, { bufnr = buffer })
      local group = vim.api.nvim_create_augroup("lsp_codelens_" .. buffer, { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        buffer = buffer,
        group = group,
        callback = function()
          vim.lsp.codelens.enable(true, { bufnr = buffer })
        end,
      })
    end

    if supports("textDocument/inlayHint", buffer) then
      vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
    end
  end,
})

return M
