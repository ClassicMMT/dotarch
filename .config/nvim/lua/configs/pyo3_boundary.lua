local M = {}

local NESTED_ROOTS = { "python", "stubs" }

function M.package_roots(start_dir)
  if not start_dir or start_dir == "" then
    return {}
  end
  local git = vim.fs.find(".git", { upward = true, path = start_dir, limit = 1 })[1]
  local top = git and vim.fs.dirname(git) or start_dir
  local paths = {}
  for name, kind in vim.fs.dir(top) do
    if kind == "directory" then
      local dir = top .. "/" .. name
      if vim.uv.fs_stat(dir .. "/pyproject.toml") or vim.uv.fs_stat(dir .. "/setup.py") then
        table.insert(paths, dir)

        for child, child_kind in vim.fs.dir(dir) do
          if child_kind == "directory" then
            for _, nested in ipairs(NESTED_ROOTS) do
              local candidate = dir .. "/" .. child .. "/" .. nested
              if vim.uv.fs_stat(candidate) then
                table.insert(paths, candidate)
              end
            end
          end
        end
      end
    end
  end
  return paths
end

function M.ranked_hits(symbol)
  local pattern = string.format([[name = "%s"|(fn|struct|enum|trait) %s\b]], symbol, symbol)
  local lines = vim.fn.systemlist { "rg", "--vimgrep", "--type", "rust", "-e", pattern }
  if vim.v.shell_error ~= 0 or #lines == 0 then
    return {}
  end

  local marker = string.format('name = "%s"', symbol)
  local exported, other = {}, {}
  for _, line in ipairs(lines) do
    table.insert(line:find(marker, 1, true) and exported or other, line)
  end

  return vim.list_extend(exported, other)
end

function M.goto_rust_definition()
  local symbol = vim.fn.expand "<cword>"
  if symbol == "" then
    return
  end

  local hits = M.ranked_hits(symbol)
  if #hits == 0 then
    vim.notify("No Rust definition found for " .. symbol, vim.log.levels.WARN)
    return
  end

  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local make_entry = require "telescope.make_entry"
  local conf = require("telescope.config").values

  pickers
    .new({}, {
      prompt_title = "Rust definition: " .. symbol,
      finder = finders.new_table {
        results = hits,
        entry_maker = make_entry.gen_from_vimgrep {},
      },
      sorter = conf.generic_sorter {},
      previewer = conf.grep_previewer {},
    })
    :find()
end

return M
