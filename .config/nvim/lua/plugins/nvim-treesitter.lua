return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- Install parsers
      require("nvim-treesitter").install {
        "bash",
        "c",
        "css",
        "gitignore",
        "html",
        "javascript",
        "json",
        "latex",
        "lua",
        "markdown",
        "python",
        "r",
        "rnoweb",
        "rust",
        "typescript",
        "typst",
        "vim",
        "vimdoc",
        "yaml",
        "xml",
      }

      -- Enable treesitter highlighting + indentation for filetypes with installed parsers
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft)
          if lang and pcall(vim.treesitter.language.inspect, lang) then
            vim.treesitter.start(args.buf)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Incremental selection via treesitter nodes
      local function incremental_select()
        local node = vim.treesitter.get_node()
        if not node then
          return
        end
        local sr, sc, er, ec = node:range()
        vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
        vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
        vim.cmd "normal! gv"
      end

      local function incremental_expand()
        local node = vim.treesitter.get_node()
        if not node then
          return
        end
        -- If we're already in visual mode, find the node covering the selection and go to its parent
        local mode = vim.fn.mode()
        if mode == "v" or mode == "V" or mode == "\22" then
          local sr = vim.fn.line "'<" - 1
          local sc = vim.fn.col "'<" - 1
          local er = vim.fn.line "'>" - 1
          local ec = vim.fn.col "'>"
          -- Find the smallest node that covers the current selection
          local root = vim.treesitter.get_node { pos = { sr, sc } }
          while root do
            local nr, nc, ner, nec = root:range()
            if nr <= sr and nc <= sc and (ner > er or (ner == er and nec >= ec)) then
              -- This node covers the selection; try parent for expansion
              local parent = root:parent()
              if parent then
                local pr, pc, per, pec = parent:range()
                if pr ~= nr or pc ~= nc or per ~= ner or pec ~= nec then
                  vim.fn.setpos("'<", { 0, pr + 1, pc + 1, 0 })
                  vim.fn.setpos("'>", { 0, per + 1, pec, 0 })
                  vim.cmd "normal! gv"
                  return
                end
              end
              break
            end
            root = root:parent()
          end
        end
        incremental_select()
      end

      local function decremental_select()
        local node = vim.treesitter.get_node()
        if not node then
          return
        end
        local child = node:child(0)
        if child then
          local sr, sc, er, ec = child:range()
          vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
          vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
          vim.cmd "normal! gv"
        end
      end

      vim.keymap.set("n", "<C-space>", incremental_select, { desc = "Init treesitter selection" })
      vim.keymap.set("v", "<C-space>", incremental_expand, { desc = "Expand treesitter selection" })
      vim.keymap.set("v", "<BS>", decremental_select, { desc = "Shrink treesitter selection" })

      -- Tree navigation across definitions (functions / methods / classes) --

      local DEF_PAT = { "function", "method", "class", "decorated" }
      local function is_def(node)
        if not node or not node:named() then
          return false
        end -- skip anonymous tokens (the `class`/`def` keywords)
        local t = node:type()
        for _, p in ipairs(DEF_PAT) do
          if t:find(p) then
            return true
          end
        end
        return false
      end

      -- Find the identifier node naming a definition (digs through decorators).
      local function def_name(node)
        local ok, field = pcall(node.field, node, "name")
        if ok and field[1] then
          return field[1]
        end
        for child in node:iter_children() do
          if is_def(child) then
            local n = def_name(child)
            if n then
              return n
            end
          end
        end
        return nil
      end

      -- Cursor target for a definition: its name if it has one, else its start.
      local function target_pos(node)
        local r, c = (def_name(node) or node):range()
        return r, c
      end

      local function move_to(node)
        if not node then
          return
        end
        local r, c = target_pos(node)
        vim.api.nvim_win_set_cursor(0, { r + 1, c })
      end

      -- Nearest enclosing definition, normalised over a decorator wrapper.
      local function enclosing_def()
        local node = vim.treesitter.get_node()
        while node do
          if is_def(node) then
            local parent = node:parent()
            if parent and parent:type():find "decorated" then
              return parent
            end
            return node
          end
          node = node:parent()
        end
        return nil
      end

      -- <C-Up>: climb to the name of the nearest enclosing definition that
      -- starts strictly before the cursor, so repeated presses keep climbing.
      local function goto_parent_def()
        local cur = vim.api.nvim_win_get_cursor(0)
        local crow, ccol = cur[1] - 1, cur[2]
        local node = vim.treesitter.get_node()
        while node do
          if is_def(node) then
            local r, c = target_pos(node)
            if r < crow or (r == crow and c < ccol) then
              return move_to(node)
            end
          end
          node = node:parent()
        end
      end

      -- First definition nested anywhere inside `node` (document order).
      local function first_child_def(node)
        for child in node:iter_children() do
          if is_def(child) then
            return child
          end
          local found = first_child_def(child)
          if found then
            return found
          end
        end
        return nil
      end

      -- <C-Down>: descend into the first definition inside the current one.
      local function goto_child_def()
        local from = enclosing_def() or vim.treesitter.get_node()
        if from then
          move_to(first_child_def(from))
        end
      end

      -- <C-Left> / <C-Right>: previous / next sibling definition at this level.
      local function goto_sibling_def(forward)
        local sib = enclosing_def()
        if not sib then
          return
        end
        repeat
          sib = forward and sib:next_named_sibling() or sib:prev_named_sibling()
        until not sib or is_def(sib)
        move_to(sib)
      end

      -- hjkl handles normal movement, so the arrow keys drive treesitter jumps:
      -- vertical = depth (up the tree / into nesting), horizontal = siblings.
      vim.keymap.set("n", "<Up>", goto_parent_def, { desc = "TS: go to enclosing definition" })
      vim.keymap.set("n", "<Down>", goto_child_def, { desc = "TS: go to first nested definition" })
      vim.keymap.set("n", "<Left>", function()
        goto_sibling_def(false) -- previous sibling (up the screen)
      end, { desc = "TS: previous sibling definition" })
      vim.keymap.set("n", "<Right>", function()
        goto_sibling_def(true) -- next sibling (down the screen)
      end, { desc = "TS: next sibling definition" })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
        },
      }

      local select = function(query)
        return function()
          require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
        end
      end

      -- assignments
      vim.keymap.set({ "x", "o" }, "a=", select "@assignment.outer", { desc = "Select outer part of an assignment" })
      vim.keymap.set({ "x", "o" }, "i=", select "@assignment.inner", { desc = "Select inner part of an assignment" })
      vim.keymap.set({ "x", "o" }, "l=", select "@assignment.lhs", { desc = "Select left hand side of an assignment" })
      vim.keymap.set({ "x", "o" }, "r=", select "@assignment.rhs", { desc = "Select right hand side of an assignment" })

      -- arguments
      vim.keymap.set(
        { "x", "o" },
        "aa",
        select "@parameter.outer",
        { desc = "Select outer part of a parameter/argument" }
      )
      vim.keymap.set(
        { "x", "o" },
        "ia",
        select "@parameter.inner",
        { desc = "Select inner part of a parameter/argument" }
      )

      -- conditions
      vim.keymap.set({ "x", "o" }, "ai", select "@conditional.outer", { desc = "Select outer part of a conditional" })
      vim.keymap.set({ "x", "o" }, "ii", select "@conditional.inner", { desc = "Select inner part of a conditional" })

      -- loops
      vim.keymap.set({ "x", "o" }, "al", select "@loop.outer", { desc = "Select outer part of a loop" })
      vim.keymap.set({ "x", "o" }, "il", select "@loop.inner", { desc = "Select inner part of a loop" })

      -- function calls
      vim.keymap.set({ "x", "o" }, "af", select "@call.outer", { desc = "Select outer part of a function call" })
      vim.keymap.set({ "x", "o" }, "if", select "@call.inner", { desc = "Select inner part of a function call" })

      -- function/method definitions
      vim.keymap.set(
        { "x", "o" },
        "am",
        select "@function.outer",
        { desc = "Select outer part of a method/function definition" }
      )
      vim.keymap.set(
        { "x", "o" },
        "im",
        select "@function.inner",
        { desc = "Select inner part of a method/function definition" }
      )

      -- classes
      vim.keymap.set({ "x", "o" }, "ac", select "@class.outer", { desc = "Select outer part of a class" })
      vim.keymap.set({ "x", "o" }, "ic", select "@class.inner", { desc = "Select inner part of a class" })
    end,
  },
}
