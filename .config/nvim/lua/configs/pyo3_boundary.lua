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

function M.goto_rust_definition()
  local symbol = vim.fn.expand "<cword>"
  if symbol == "" then
    return
  end

  require("telescope.builtin").grep_string {
    search = string.format([[name = "%s"|fn %s\b]], symbol, symbol),
    use_regex = true,
    additional_args = { "--type", "rust" },
    prompt_title = "Rust definition: " .. symbol,
  }
end

return M
