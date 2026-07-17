local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettierd" },

    -- markdown = { "prettier" },  -- commented out because prettier reformats tables in unwanted ways
    -- python = { "isort", "black" },
    -- python = { "isort" },
    json = { "prettier" },
    javascript = { "prettier" },
    -- install in R: install.packages("styler")
    r = { "styler" },
    rmd = { "styler" },
    -- conform runs rustfmt from the nearest rustfmt.toml dir and
    -- detects the edition from Cargo.toml,
    -- so each crate's own style is honoured
    rust = { "rustfmt" },
  },

  formatters = {
    prettierd = {
      args = { "--stdin-filepath", "$FILENAME", "--parser=html", "--print-width=120" },
    },
  },

  format_on_save = {
    -- passed to conform.format()
    timeout_ms = 500,
    async = false,
    lsp_fallback = true,
  },
}

return options
