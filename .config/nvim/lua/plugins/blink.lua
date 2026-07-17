return {
  {
    import = "nvchad.blink.lazyspec",
  },

  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdLineEnter" },
    opts = function()
      local base_opts = require "nvchad.blink.config"

      -- Keymaps matching nvim-cmp configuration
      base_opts.keymap = {
        preset = "none",
        ["<C-k>"] = { "show", "select_prev", "fallback" },
        ["<C-j>"] = { "show", "select_next", "fallback" },
        ["<Up>"] = { "show", "select_prev", "fallback" },
        ["<Down>"] = { "show", "select_next", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-Space>"] = { "show", "fallback" },
        ["<Esc>"] = { "hide", "fallback" },
        ["<Tab>"] = { "select_and_accept", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },
      }

      base_opts.cmdline = {
        enabled = true,
        sources = { "cmdline", "buffer" },
        keymap = {
          preset = "none",
          ["<C-j>"] = { "show", "select_next", "fallback" },
          ["<C-k>"] = { "show", "select_prev", "fallback" },
          ["<Down>"] = { "show", "select_next", "fallback" },
          ["<Up>"] = { "show", "select_prev", "fallback" },
          ["<Tab>"] = { "select_and_accept", "fallback" },
          ["<CR>"] = { "accept", "fallback" },
        },
        completion = {
          menu = {
            auto_show = true,
          },
          list = {
            selection = {
              preselect = false,
              auto_insert = false,
            },
          },
        },
      }

      base_opts.completion = {
        ghost_text = {
          enabled = false,
        },
        trigger = {
          show_on_insert_on_trigger_character = true,
          show_on_accept_on_trigger_character = false,
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        menu = vim.tbl_deep_extend("force", require("nvchad.blink").menu, {}),
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "single",
          },
        },
      }

      base_opts.fuzzy = {
        implementation = "rust",
      }

      base_opts.sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            enabled = true,
            should_show_items = true,
            trigger_characters = nil,
            score_offset = 1000,
          },
        },
      }

      return base_opts
    end,

    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "L3MON4D3/LuaSnip",
        dependencies = "rafamadriz/friendly-snippets",
        opts = { history = true, updateevents = "TextChanged,TextChangedI" },
        config = function(_, opts)
          require("luasnip").config.set_config(opts)
          require "nvchad.configs.luasnip"
          require("luasnip.loaders.from_vscode").lazy_load()
          require("snippets").load()
        end,
      },

      {
        "windwp/nvim-autopairs",
        opts = {
          fast_wrap = {},
          disable_filetype = { "telescopeprompt", "vim" },
        },
      },
    },

    opts_extend = { "sources.default" },
  },
}
