local nvlsp = require "nvchad.configs.lspconfig"
local map = vim.keymap.set

vim.o.winborder = "rounded"

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local function opts(desc)
      return { buffer = bufnr, desc = "LSP " .. desc }
    end

    map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
    map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
    map("n", "gi", vim.lsp.buf.implementation, opts "Go to implementation")
    map("n", "<leader>gt", vim.lsp.buf.type_definition, opts "Go to type definition")
    map("n", "<leader>ra", require "nvchad.lsp.renamer", opts "NvRenamer")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
    map("n", "gr", "<cmd>Telescope lsp_references<cr>", opts "Show references")
  end,
})

-- auto-restart crashing lsp servers
vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      return
    end
    -- Client no longer exists — it crashed/exited unexpectedly
    -- Find which server was attached to this buffer and restart it
    vim.defer_fn(function()
      local buf = args.buf
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      -- Re-trigger FileType to let vim.lsp.enable pick up the buffer
      local ft = vim.bo[buf].filetype
      if ft and ft ~= "" then
        vim.notify("Restarting LSP for filetype: " .. ft, vim.log.levels.INFO)
        vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
      end
    end, 1000)
  end,
})

-- Load LSP diagnostics config
require("nvchad.lsp").diagnostic_config()
dofile(vim.g.base46_cache .. "lsp")

-- Set up capabilities for blink.cmp
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Configure global LSP settings (applies to all servers)
vim.lsp.config("*", {
  capabilities = capabilities,
  on_init = nvlsp.on_init, -- Disables semantic tokens for better performance
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
          vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
          "${3rd}/luv/library",
        },
      },
      diagnostics = {
        globals = { "vim" },
      },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.enable "lua_ls"

local function discover_extra_paths(start_dir)
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
      end
    end
  end
  return paths
end

-- jedi-language-server reads these from initializationOptions (NOT workspace/configuration),
-- so they must go under `init_options`, with top-level camelCase keys.
local jedi_init_options = {
  markupKindPreferred = "markdown",
  jediSettings = {
    autoImportModules = { "transformers" },
    caseInsensitiveCompletion = true,
  },
}

vim.lsp.config("jedi_language_server", {
  filetypes = { "python" },
  capabilities = {
    general = {
      positionEncodings = { "utf-32" },
    },
  },
  init_options = jedi_init_options,
  before_init = function(params, config)
    local opts = vim.deepcopy(jedi_init_options)
    opts.workspace = { extraPaths = discover_extra_paths(config.root_dir) }
    params.initializationOptions = opts
  end,
})
vim.lsp.enable "jedi_language_server"

vim.lsp.config("ruff", {
  filetypes = { "python" },
  -- init_options = {
  --   settings = {
  --     lineLength = 120,
  --     lint = {
  --       enable = true,
  --       select = { "F", "E", "W" },
  --     },
  --   },
  -- },
})
vim.lsp.enable "ruff"

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemas = {},
      validate = true,
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      hover = true,
      completion = true,
    },
  },
})
vim.lsp.enable "yamlls"

vim.lsp.config("marksman", {
  filetypes = { "markdown" },
})
vim.lsp.enable "marksman"

-- vim.lsp.config("basedpyright", {
--   filetypes = { "python" },
--   settings = {
--     basedpyright = {
--       analysis = {
--         autoSearchPaths = false,
--         useLibraryCodeForTypes = false,
--         autoImportCompletions = false,
--         diagnosticMode = "openFilesOnly",
--         typeCheckingMode = "off",
--         exclude = {
--           "**/node_modules",
--           "**/__pycache__",
--           "**/.*",
--           "**/.venv",
--           "**/venv",
--           "**/env",
--         },
--         stubPath = vim.fn.expand "~/.local/share/python-type-stubs/stubs",
--         logLevel = "Error",
--         diagnosticSeverityOverrides = {
--           strictListInference = true,
--           strictDictionaryInference = true,
--           strictSetInference = true,
--           reportUnusedExpression = "none",
--           reportUnusedCoroutine = "none",
--           reportUnusedClass = "none",
--           reportUnusedImport = "none",
--           reportUnusedFunction = "none",
--           reportUnusedVariable = "none",
--           reportUnusedCallResult = "none",
--           reportDuplicateImport = "warning",
--           reportPrivateUsage = "none",
--           reportConstantRedefinition = "none",
--           reportUndefinedVariable = "error",
--         },
--         inlayHints = {
--           variableTypes = false,
--           functionReturnTypes = false,
--           pytestParameters = false,
--           callArgumentNames = false,
--         },
--       },
--     },
--   },
-- })
-- vim.lsp.enable "basedpyright"
