return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    "nvim-telescope/telescope-live-grep-args.nvim",
  },
  opts = function()
    local conf = require "nvchad.configs.telescope"
    local action_set = require "telescope.actions.set"
    local lga_actions = require "telescope-live-grep-args.actions"
    local sorters = require "telescope.sorters"

    local function grep_term(prompt)
      local term = prompt:match '"(.-)"' or prompt:match "^%S+" or prompt
      return vim.trim(term or "")
    end

    local function boundary_grep_sorter()
      return sorters.Sorter:new {
        discard = false,
        scoring_function = function(_, prompt, _, entry)
          local term = grep_term(prompt)
          local text = entry and entry.text or ""
          if term == "" or text == "" then
            return 1
          end
          local s = text:lower():find(term:lower(), 1, true)
          if not s then
            return 1 -- regex / multi-word match rg found but we can't locate; neutral
          end
          local prev = s > 1 and text:sub(s - 1, s - 1) or ""
          local glued = prev:match "[%w_]" ~= nil
          -- primary: boundary matches first; tiebreak: earlier column.
          return (glued and 1000 or 0) + s
        end,
        -- Highlight every literal occurrence of the term in the result line.
        highlighter = function(_, prompt, display)
          local term = grep_term(prompt)
          if term == "" then
            return {}
          end
          local positions, ld, lt, start = {}, display:lower(), term:lower(), 1
          while true do
            local s, e = ld:find(lt, start, true)
            if not s then
              break
            end
            for i = s, e do
              positions[#positions + 1] = i
            end
            start = e + 1
          end
          return positions
        end,
      }
    end

    conf.defaults.vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--no-ignore",
      "--glob=!*.ipynb",
      "--glob=!*.json",
      "--glob=!*.log",
      "--glob=!.git/*",
    }

    -- Fix underscore matching issues
    conf.defaults.sorting_strategy = "ascending"
    conf.defaults.layout_config = {
      prompt_position = "top",
    }

    conf.pickers = {
      find_files = {
        find_command = { "rg", "--files", "--no-ignore", "--glob", "!.git/*" },
      },
    }

    conf.extensions = conf.extensions or {}
    conf.extensions.live_grep_args = {
      auto_quoting = true,
      sorter = boundary_grep_sorter(),
      mappings = {
        i = {
          ["<C-b>"] = lga_actions.quote_prompt(),
          ["<C-g>"] = lga_actions.quote_prompt { postfix = " --iglob " },
        },
      },
    }

    conf.defaults.mappings = conf.defaults.mappings or {}
    conf.defaults.mappings.n = conf.defaults.mappings.n or {}
    conf.defaults.mappings.n["J"] = function(bufnr)
      action_set.shift_selection(bufnr, 5)
    end
    conf.defaults.mappings.n["K"] = function(bufnr)
      action_set.shift_selection(bufnr, -5)
    end

    return conf
  end,
  config = function(_, opts)
    local telescope = require "telescope"
    telescope.setup(opts)

    telescope.load_extension "fzf"
    telescope.load_extension "live_grep_args"
  end,
}
