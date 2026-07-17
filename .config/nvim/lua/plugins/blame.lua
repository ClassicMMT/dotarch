return {
  "FabijanZulj/blame.nvim",
  cmd = { "BlameToggle" },
  keys = {
    { "<leader>gb", "<cmd>BlameToggle<cr>", desc = "git blame toggle" },
  },
  opts = {},
  config = function(_, opts)
    require("blame").setup(opts)

    local group = vim.api.nvim_create_augroup("BlameScrollSync", { clear = true })
    local syncing = false

    local function find_windows()
      local blame_win, code_win
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "blame" then
          blame_win = win
        elseif vim.bo[buf].buftype == "" and vim.api.nvim_win_get_config(win).relative == "" then
          code_win = code_win or win
        end
      end
      return blame_win, code_win
    end

    local function mirror(src, dst)
      if syncing then
        return
      end
      syncing = true
      pcall(function()
        local topline = vim.fn.line("w0", src)
        local lnum = vim.api.nvim_win_get_cursor(src)[1]
        local last = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(dst))
        vim.api.nvim_win_call(dst, function()
          local view = vim.fn.winsaveview()
          view.topline = topline
          view.lnum = math.min(lnum, last)
          view.leftcol = 0
          vim.fn.winrestview(view)
        end)
      end)
      syncing = false
    end

    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "BlameViewOpened",
      callback = function()
        local active = vim.api.nvim_create_augroup("BlameScrollSyncActive", { clear = true })

        vim.api.nvim_create_autocmd("WinScrolled", {
          group = active,
          callback = function()
            local blame_win, code_win = find_windows()
            if not (blame_win and code_win) then
              return
            end
            local event = vim.v.event
            if event[tostring(blame_win)] then
              mirror(blame_win, code_win)
            elseif event[tostring(code_win)] then
              mirror(code_win, blame_win)
            end
          end,
        })

        vim.api.nvim_create_autocmd("CursorMoved", {
          group = active,
          callback = function()
            local blame_win, code_win = find_windows()
            if not (blame_win and code_win) then
              return
            end
            local current = vim.api.nvim_get_current_win()
            if current == blame_win then
              mirror(blame_win, code_win)
            elseif current == code_win then
              mirror(code_win, blame_win)
            end
          end,
        })
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "BlameViewClosed",
      callback = function()
        pcall(vim.api.nvim_del_augroup_by_name, "BlameScrollSyncActive")
      end,
    })
  end,
}
