return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gitsigns = require "gitsigns"

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal { "]c", bang = true }
        else
          gitsigns.nav_hunk "next"
        end
      end, "next git hunk")

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal { "[c", bang = true }
        else
          gitsigns.nav_hunk "prev"
        end
      end, "previous git hunk")

      map("n", "<leader>hs", gitsigns.stage_hunk, "stage hunk")
      map("n", "<leader>hr", gitsigns.reset_hunk, "reset hunk")

      map("v", "<leader>hs", function()
        gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
      end, "stage selected hunk")

      map("v", "<leader>hr", function()
        gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
      end, "reset selected hunk")

      map("n", "<leader>hS", gitsigns.stage_buffer, "stage buffer")
      map("n", "<leader>hR", gitsigns.reset_buffer, "reset buffer")
      map("n", "<leader>hp", gitsigns.preview_hunk, "preview hunk")
      map("n", "<leader>hb", gitsigns.blame_line, "blame line")
      map("n", "<leader>hd", gitsigns.diffthis, "diff against index")
      map("n", "<leader>hq", gitsigns.setqflist, "hunks to quickfix")
    end,
  },
}
