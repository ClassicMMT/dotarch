local function toggle(open)
  return function()
    if require("diffview.lib").get_current_view() then
      vim.cmd "DiffviewClose"
    else
      vim.cmd(open)
    end
  end
end

local function equalize()
  local view = require("diffview.lib").get_current_view()
  if not view or not view.cur_layout then
    return
  end

  local wins = vim.tbl_filter(function(win)
    return vim.api.nvim_win_is_valid(win.id)
  end, view.cur_layout.windows)

  if #wins < 2 then
    return
  end

  local total = 0
  for _, win in ipairs(wins) do
    total = total + vim.api.nvim_win_get_width(win.id)
  end

  local target = math.floor(total / #wins)
  for _, win in ipairs(wins) do
    vim.api.nvim_win_set_width(win.id, target)
  end
end

local equalize_map = { "n", "<leader>re", equalize, { desc = "Equalize diff panes" } }

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>dd", toggle "DiffviewOpen", desc = "Toggle diffview working tree" },
    { "<leader>dv", toggle "DiffviewOpen origin/HEAD...HEAD --imply-local", desc = "Toggle diffview changes" },
    { "<leader>dh", toggle "DiffviewFileHistory --range=origin/HEAD..HEAD", desc = "Toggle diffview commits" },
  },
  opts = {
    keymaps = {
      view = { equalize_map },
      file_panel = { equalize_map },
      file_history_panel = { equalize_map },
    },
    hooks = {
      diff_buf_win_enter = function(bufnr)
        local map = function(lhs, rhs)
          vim.keymap.set({ "n", "x" }, lhs, rhs, { buffer = bufnr, silent = true })
        end
        map("<ScrollWheelUp>", "3<C-y>")
        map("<ScrollWheelDown>", "3<C-e>")
      end,
    },
  },
}
