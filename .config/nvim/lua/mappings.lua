-- require "nvchad.mappings"

local map = vim.keymap.set

-- MY MAPPINGS (NvChad mappings follow this section) --

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- for omarchy clipboard
map("v", "<C-Insert>", '"+y', { desc = "Copy to clipboard" })
map("n", "<C-Insert>", '"+yy', { desc = "Copy line to clipboard" })
map({ "n", "v" }, "<S-Insert>", '"+p', { desc = "Paste from clipboard" })
map("i", "<S-Insert>", "<C-r>+", { desc = "Paste from clipboard" })

-- shift enter opens new line from insert mode
map("i", "<S-CR>", "<ESC>o")

-- Don't leave visual mode when changing indent or yank
map("x", ">", ">gv", { noremap = true })
map("x", "<", "<gv", { noremap = true })
-- map("v", "y", "ygv", { noremap = true })

map("v", "p", "P", { noremap = true, silent = true })

-- Remap $ and ^
map({ "n", "x" }, "H", "^")
map({ "n", "x" }, "L", "$")

-- decrement/increment with -/+
map({ "n", "x" }, "-", "<C-x>")
map({ "n", "x" }, "+", "<C-a>")

-- disable highlights for * and #
map({ "n" }, "*", function()
  vim.cmd "normal! *"
  vim.cmd "nohl"
end)
map({ "n" }, "#", function()
  vim.cmd "normal! #"
  vim.cmd "nohl"
end)

-- exclude motions from jumplist
for _, key in ipairs { "{", "}", "M" } do
  map("n", key, function()
    vim.cmd("keepjumps normal! " .. vim.v.count1 .. key)
  end, { desc = "Move by " .. key .. " (no jumplist)" })
end

-- open messages
map("n", "<leader>mm", "<CMD>messages<CR>", { desc = "Show messages" })

-- jump to and from terminal
-- map("n", "<C-j>", "<C-w><C-w>")
map("t", "<Esc>", "<C-\\><C-N>") -- exit insert mode
-- map("n", "<C-k>", "<C-w><C-w>")

-- exit terminal even when in insert mode
map("t", "<C-h>", "<C-\\><C-n><C-w>h")
map("t", "<C-j>", "<C-\\><C-n><C-w>j")
map("t", "<C-k>", "<C-\\><C-n><C-w>k")
map("t", "<C-l>", "<C-\\><C-n><C-w>l")

-- Comment
map("n", "''", "gcc", { desc = "toggle comment", remap = true })
map("v", "''", "gc", { desc = "toggle comment", remap = true })

-- Remap some nvim 0.11 mappings
map("n", "[<CR>", "[<space>", { desc = "Add empty line above" })
map("n", "]<CR>", "]<space>", { desc = "Add empty line before" })

-- Allow ciw da( etc for other symbols
local chars = { "_", ".", ":", ",", ";", "|", "/", "\\", "*", "+", "%", "`", "?", "$", "=" }
for _, char in ipairs(chars) do
  for _, mode in ipairs { "x", "o" } do
    vim.api.nvim_set_keymap(
      mode,
      "i" .. char,
      string.format(":<C-u>silent! normal! f%sF%slvt%s<CR>", char, char, char),
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      mode,
      "a" .. char,
      string.format(":<C-u>silent! normal! f%sF%svf%s<CR>", char, char, char),
      { noremap = true, silent = true }
    )
  end
end

-- Allow cil val to better copy lines
map({ "n" }, "yl", function()
  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("0y$", true, false, true), "n", true)
end, { noremap = true, silent = true, expr = true })

-- get buffer path
map({ "n", "v" }, "<leader>yp", function()
  local filepath = vim.fn.expand "%:p"
  vim.fn.setreg("+", filepath)
end, { desc = "Path copy to clipboard" })

-- get buffer's directory
map({ "n", "v" }, "<leader>yd", function()
  local dir = vim.fn.expand "%:p:h"
  vim.fn.setreg("+", dir)
end, { desc = "Dir copy to clipboard" })

-- macos-like shortcuts
map("i", "<C-BS>", function()
  -- like command backspace
  if vim.fn.col "." == 1 then
    return "<BS>"
  else
    return "<ESC>d0xi"
  end
end, { expr = true, noremap = true })

map("n", "<C-BS>", function()
  -- like command backspace
  if vim.fn.col "." == 1 then
    return "X"
  else
    return "d0x"
  end
end, { expr = true, noremap = true })

map("i", "<M-BS>", function()
  -- like option backspace
  if vim.fn.col "." == 1 then
    return "<BS>"
  else
    return "<ESC>dbxi"
  end
end, { expr = true, noremap = true })

map("n", "<M-BS>", function()
  -- like option backspace
  if vim.fn.col "." == 1 then
    return "X"
  else
    return "dbx"
  end
end, { expr = true, noremap = true })

-- transparency toggle
map("n", "<leader>tt", function()
  require("base46").toggle_transparency()
end, { desc = "Toggle Transparency" })

-- floating diagnostic
map("n", "gh", function()
  vim.diagnostic.open_float(nil, { focus = false })
end, { noremap = true, silent = true })

map("n", "<leader>ih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle Inlay Hints" })

-- Buffer navigation
map("n", "<leader>b", ":b#<CR>", { desc = "Jump to Previous Buffer" })

-- END OF MY MAPPINGS --

-- Modified nvchad.mappings
map("i", "<C-h>", "<Left>", { desc = "move left" })
map("i", "<C-l>", "<Right>", { desc = "move right" })
-- Disabled to allow blink.cmp to use these for completion selection
-- map("i", "<C-j>", "<Down>", { desc = "move down" })
-- map("i", "<C-k>", "<Up>", { desc = "move up" })

map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>cc", 'gg"_cG', { desc = "general change whole file" })

-- Line numbers
-- map("n", "<leader>nn", "<cmd>set nu!<CR>", { desc = "toggle line number" })
-- map("n", "<leader>nr", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
-- map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

-- map("n", "<leader>fm", function()
--   require("conform").format { lsp_fallback = true }
-- end, { desc = "general format file" })

-- global lsp mappings
map("n", "<leader>ld", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-- tabufline
-- map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })
--
-- map("n", "<C-t>", function()
--   require("nvchad.tabufline").next()
-- end, { desc = "buffer goto next" })

-- map("n", "<C-p>", function()
--   require("nvchad.tabufline").prev()
-- end, { desc = "buffer goto prev" })

-- map("n", "<leader>xx", function()
--   require("nvchad.tabufline").close_buffer()
-- end, { desc = "buffer close" })

-- nvimtree
map("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer to current location" })
-- map("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
-- map("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })

-- telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
-- map("n", "<leader>ff", "<cmd>Telescope frecency workspace=CWD<cr>", { desc = "telescope find files" })
-- map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find recent files" })
map("n", "<leader>fo", "<cmd>Telescope frecency<CR>", { desc = "telescope find recent files" })
map("n", "<leader>fs", function()
  require("telescope").extensions.live_grep_args.live_grep_args()
end, { desc = "telescope live grep (with rg args)" })
-- Same picker, but without the default glob exclusions (searches ipynb/json/log/etc.)
map("n", "<leader>fS", function()
  require("telescope").extensions.live_grep_args.live_grep_args {
    vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--no-ignore",
      "--glob=!.git/*",
    },
  }
end, { desc = "telescope live grep (all files, no excludes)" })
map("n", "<leader>fd", "<cmd>Telescope resume<CR>", { desc = "telescope resume last picker" })
map("n", "<leader>fl", "`0", { desc = "jump to last file/position on quit" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
-- map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })
-- map("n", "<leader>fb", "<cmd>telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>fb", function()
  -- require("telescope.builtin").buffers { initial_mode = "normal" }
  require("telescope.builtin").buffers()
end, { desc = "telescope find buffers" })
-- map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })

map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

-- themes
map("n", "<leader>tc", function()
  require("nvchad.themes").open()
end, { desc = "telescope nvchad themes" })

-- git
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "git commits" })
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "git status" })
