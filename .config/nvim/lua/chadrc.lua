-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
---@diagnostic disable: missing-fields
local M = {}

M.mason = {
  cmd = true,
  pkgs = {
    -- "mypy",
    "debugpy",
    "yaml-language-server",
  },
}

M.ui = {
  -- disable tabufline
  tabufline = {
    enabled = false,
  },

  statusline = {
    -- theme = minimal, separator = round is very nice, if no artifacts
    theme = "minimal",
    separator_style = "round",

    modules = {
      git = function()
        local max_len = 18 -- max chars of the branch name before truncating

        local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
        if not vim.b[bufnr].gitsigns_head or vim.b[bufnr].gitsigns_git_status then
          return ""
        end

        local nr2char = vim.fn.nr2char
        local g_branch, g_add, g_chg, g_rem = nr2char(0xEA68), nr2char(0xF055), nr2char(0xF459), nr2char(0xF146)

        local st = vim.b[bufnr].gitsigns_status_dict
        local branch = st.head or ""
        if vim.fn.strchars(branch) > max_len then
          branch = vim.fn.strcharpart(branch, 0, max_len - 1) .. "…"
        end

        local added = (st.added and st.added ~= 0) and (" " .. g_add .. " " .. st.added) or ""
        local changed = (st.changed and st.changed ~= 0) and (" " .. g_chg .. " " .. st.changed) or ""
        local removed = (st.removed and st.removed ~= 0) and (" " .. g_rem .. " " .. st.removed) or ""

        return "%#St_gitIcons#" .. " " .. g_branch .. " " .. branch .. added .. changed .. removed
      end,

      -- Show just the active client name, no icon / no "LSP ~" prefix.
      lsp = function()
        if rawget(vim, "lsp") then
          local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
          for _, client in ipairs(vim.lsp.get_clients()) do
            if client.attached_buffers[bufnr] then
              return "%#St_Lsp#" .. " " .. client.name .. " "
            end
          end
        end
        return ""
      end,
    },
  },
}

M.base46 = {
  theme = "onedark",
  transparency = true,

  integrations = {
    "rainbowdelimiters",
  },

  changed_themes = {
    onedark = {
      base_16 = {
        base08 = "#CB737A",
        base09 = "#BE9670",
        base0A = "#D0B37C",
        base0B = "#95B47E",
        base0C = "#66A9B2",
        base0D = "#6AA6D6",
        base0E = "#B77BC9",
        base0F = "#AE635C",
      },
      base_30 = {
        red = "#CB737A",
        baby_pink = "#CB888D",
        pink = "#E67498",
        green = "#95B47E",
        vibrant_green = "#81BA97",
        nord_blue = "#839BB3",
        blue = "#6AA6D6",
        yellow = "#D2B884",
        sun = "#D6BB86",
        purple = "#CB8AE8",
        dark_purple = "#B981D2",
        teal = "#6396AC",
        orange = "#E89198",
        cyan = "#95A8DB",
      },
    },
  },

  hl_override = {
    ["@comment"] = { italic = true, fg = "#c3c3c3" },

    DiffAdd = { fg = "NONE" },
    DiffChange = { fg = "NONE" },

    LspInlayHint = {
      fg = "#4f4f4f",
      bg = "NONE",
      italic = true,
    },

    -- change matching parantheses colours
    MatchWord = {
      bg = "#e0e0e0",
      fg = "#000000",
      bold = true,
    },
  },
}

return M
