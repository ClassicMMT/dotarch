return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
    "jay-babu/mason-null-ls.nvim",
  },
  event = {
    "BufReadPre",
    "BufNewfile",
    -- "BufEnter", -- probably unnecessary
  },
  ft = { "python" },
  config = function()
    require("mason-null-ls").setup {
      ensure_installed = {
        "ruff",
        "prettier",
        "shfmt",
        "prettierd",
        "tinymist",
        "vale",
      },
      automatic_installation = true,
    }

    local null_ls = require "null-ls"
    local sources = {
      null_ls.builtins.formatting.prettierd.with {
        filetypes = {
          "json",
          "yaml",
        },
      },

      null_ls.builtins.formatting.shfmt.with { args = { "-i", "4" } },
      require("none-ls.formatting.ruff"),
      -- .with {
      --   extra_args = { "--line-length", "120", "--extend-ignore", "F401" },
      -- },
      -- null_ls.builtins.diagnostics.vale.with {
      --   filetypes = { "markdown", "text", "rmd" },
      -- },
    }

    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    null_ls.setup {
      -- debug = true, -- Enable debug mode. Inspect logs with :NullLsLog
      sources = sources,
      on_attach = function(client, bufnr)
        if client.supports_method and client:supports_method "textDocument/formatting" then
          vim.api.nvim_clear_autocmds {
            group = augroup,
            buffer = bufnr,
          }
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format { async = false, bufnr = bufnr }
            end,
          })
        end
      end,
    }
  end,
}
