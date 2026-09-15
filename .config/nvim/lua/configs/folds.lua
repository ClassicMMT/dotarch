local M = {}

local DECLARATIONS = {
  rust = {
    enum_item = true,
    function_item = true,
    impl_item = true,
    macro_definition = true,
    mod_item = true,
    struct_item = true,
    trait_item = true,
    union_item = true,
  },
  python = {
    class_definition = true,
    function_definition = true,
  },
  lua = {
    function_declaration = true,
    function_definition = true,
  },
}

local HEADER_PREFIX = {
  rust = { attribute_item = true, block_comment = true, line_comment = true },
  python = { comment = true, decorator = true },
  lua = { comment = true },
}

local MIN_FOLD_LINES = 4

local cache = {}

local function body_of(node)
  local body = node:field("body")[1]
  if body then
    return body
  end

  for i = node:named_child_count() - 1, 0, -1 do
    local child = node:named_child(i)
    local node_type = child:type()
    if node_type == "block" or node_type:match "_list$" then
      return child
    end
  end
end

local function header_start(node, prefixes)
  local first = node:start()
  local prev = node:prev_named_sibling()

  while prev and prefixes[prev:type()] do
    local prev_end = prev:end_()
    if prev_end + 1 < first then
      break
    end

    first = prev:start()
    prev = prev:prev_named_sibling()
  end

  return first
end

local function compute(bufnr)
  local levels = {}

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return levels
  end

  local declarations = DECLARATIONS[parser:lang()]
  if not declarations then
    return levels
  end

  local tree = parser:parse()[1]
  if not tree then
    return levels
  end

  local prefixes = HEADER_PREFIX[parser:lang()] or {}

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for row = 1, #lines do
    levels[row] = 1
  end

  local function set_range(first_row, last_row, level)
    for row = first_row, last_row do
      levels[row + 1] = level
    end
  end

  local function visit(node, depth)
    for child in node:iter_children() do
      if child:named() then
        if declarations[child:type()] then
          local body = body_of(child)
          local header_last = body and body:start() or child:start()

          set_range(header_last + 1, child:end_(), depth + 1)
          set_range(header_start(child, prefixes), header_last, 0)
          visit(child, depth + 1)
        else
          visit(child, depth)
        end
      end
    end
  end

  visit(tree:root(), 0)

  for row = #lines, 1, -1 do
    if levels[row + 1] == 0 and lines[row]:match "^%s*$" then
      levels[row] = 0
    end
  end

  local run_start
  for row = 1, #lines + 1 do
    if levels[row] and levels[row] > 0 then
      run_start = run_start or row
    elseif run_start then
      if row - run_start < MIN_FOLD_LINES then
        for unfolded = run_start, row - 1 do
          levels[unfolded] = 0
        end
      end
      run_start = nil
    end
  end

  return levels
end

local function levels_for(bufnr)
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  local entry = cache[bufnr]

  if not entry or entry.tick ~= tick then
    entry = { tick = tick, levels = compute(bufnr) }
    cache[bufnr] = entry
  end

  return entry.levels
end

function M.foldexpr()
  return levels_for(vim.api.nvim_get_current_buf())[vim.v.lnum] or 0
end

function M.foldtext()
  local indent = vim.fn.getline(vim.v.foldstart):match "^%s*"
  local count = vim.v.foldend - vim.v.foldstart + 1

  return indent .. "⋯ " .. count .. (count == 1 and " line" or " lines")
end

function M.toggle()
  if vim.wo.foldmethod == "expr" and vim.wo.foldenable then
    vim.wo.foldmethod = "manual"
    vim.wo.foldenable = false
    vim.wo.foldcolumn = "0"
    return
  end

  local ok, parser = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
  if not ok or not parser or not DECLARATIONS[parser:lang()] then
    vim.notify("skeleton folds: no declaration list for this filetype", vim.log.levels.WARN)
    return
  end

  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr = "v:lua.require'configs.folds'.foldexpr()"
  vim.wo.foldtext = "v:lua.require'configs.folds'.foldtext()"
  vim.wo.foldcolumn = "1"
  vim.wo.foldenable = true
  vim.wo.foldlevel = 0
  vim.opt_local.fillchars:append { fold = " " }
end

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  callback = function(args)
    cache[args.buf] = nil
  end,
})

vim.keymap.set("n", "<leader>zz", M.toggle, { desc = "toggle skeleton folds" })

return M
