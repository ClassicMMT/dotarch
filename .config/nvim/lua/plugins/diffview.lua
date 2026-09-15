local function base_rev()
  local refs = vim.fn.systemlist {
    "git", "for-each-ref", "--no-contains", "HEAD", "--format=%(refname)", "refs/heads/",
  }
  if vim.v.shell_error ~= 0 or #refs == 0 then
    return "origin/HEAD"
  end

  local cmd = vim.list_extend({ "git", "rev-list", "--boundary", "HEAD", "--not" }, refs)
  local out = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return "origin/HEAD"
  end

  for _, line in ipairs(out) do
    if line:sub(1, 1) == "-" then
      return line:sub(2)
    end
  end

  return "origin/HEAD"
end

local function toggle(open)
  return function()
    if require("diffview.lib").get_current_view() then
      vim.cmd "DiffviewClose"
    else
      vim.cmd(type(open) == "function" and open() or open)
    end
  end
end

local function toggle_base(template)
  return toggle(function()
    return string.format(template, base_rev())
  end)
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
    { "<leader>dv", toggle_base "DiffviewOpen %s...HEAD --imply-local", desc = "Toggle diffview changes" },
    { "<leader>dh", toggle_base "DiffviewFileHistory --range=%s..HEAD", desc = "Toggle diffview commits" },
  },
  opts = {
    file_history_panel = {
      win_config = {
        position = "left",
        width = 40,
      },
    },
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
