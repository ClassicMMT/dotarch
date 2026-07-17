return {
  {
    "gbprod/cutlass.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {

      cut_key = "x",
      -- keys used  by flash.nvim
      exclude = { "ns", "nS" },
    },
  },

  {
    "nvim-telescope/telescope-frecency.nvim",
    version = "*",
    config = function()
      require("telescope").load_extension "frecency"
      require("frecency.config").setup {
        auto_validate = true,
        ignore_patterns = { "*/.git", "*/.git/*", "*/.DS_Store" },
      }
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      -- q, p, d, c labels removed
      labels = "asfghjklwertuiozxvbnm",
      highlight = {
        backdrop = false, -- stops the screen greying out when flash is used with "s"
      },
      modes = {
        char = {
          enabled = true,
          multi_line = false,
          jump_labels = false,
          label = { exclude = "hjkliadcr" },
          highlight = { backdrop = false },
          -- jump = {
          --   autojump = true,
          -- },
          autohide = true,
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    "kylechui/nvim-surround",
    event = { "BufReadPre", "BufNewFile" },
    version = "*",
    config = function()
      -- disable default keymaps for flash.nvim
      vim.g.nvim_surround_no_defaults = true
      require("nvim-surround").setup {}

      -- keymaps changed to play better with flash.nvim
      vim.keymap.set("i", "<C-g>s", "<Plug>(nvim-surround-insert)", { desc = "Surround insert" })
      vim.keymap.set("i", "<C-g>S", "<Plug>(nvim-surround-insert-line)", { desc = "Surround insert line" })
      vim.keymap.set("n", "<leader>s", "<Plug>(nvim-surround-normal)", { desc = "Surround" })
      vim.keymap.set("n", "<leader>ss", "<Plug>(nvim-surround-normal-cur)", { desc = "Surround line" })
      vim.keymap.set("n", "<leader>S", "<Plug>(nvim-surround-normal-line)", { desc = "Surround line (newlines)" })
      vim.keymap.set(
        "n",
        "<leader>SS",
        "<Plug>(nvim-surround-normal-cur-line)",
        { desc = "Surround cur line (newlines)" }
      )
      vim.keymap.set("x", "<leader>s", "<Plug>(nvim-surround-visual)", { desc = "Surround visual" })
      vim.keymap.set("x", "<leader>S", "<Plug>(nvim-surround-visual-line)", { desc = "Surround visual line" })
      vim.keymap.set("n", "<leader>ds", "<Plug>(nvim-surround-delete)", { desc = "Surround delete" })
      vim.keymap.set("n", "<leader>cs", "<Plug>(nvim-surround-change)", { desc = "Surround change" })
      vim.keymap.set("n", "<leader>cS", "<Plug>(nvim-surround-change-line)", { desc = "Surround change line" })
    end,
  },

  {
    "andymass/vim-matchup",
    event = "BufReadPre",
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  {
    "szw/vim-maximizer",
    keys = {
      { "<leader>mt", "<cmd>MaximizerToggle<CR>", desc = "Maximizer" .. " Split maximiser toggle" },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false, -- Load immediately to get :LspInfo command
  },

  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has "nvim-0.10.0" == 1,
  },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
}
