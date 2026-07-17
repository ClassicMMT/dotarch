return {
  "https://git.barrettruth.com/barrettruth/preview.nvim",
  ft = { "markdown", "rst" },
  init = function()
    vim.g.preview = {
      typst = true,
      latex = true,
      github = {
        args = function(ctx)
          local template = vim.fn.stdpath "config" .. "/templates/preview-style.html"
          return {
            "-f",
            "gfm",
            ctx.file,
            "-s",
            "--katex",
            "--no-highlight",
            "-o",
            ctx.output,
            "--template",
            template,
          }
        end,
        output = function(ctx)
          return "/tmp/" .. vim.fn.fnamemodify(ctx.file, ":t:r") .. ".html"
        end,
      },
      rst = {
        cmd = { "pandoc" },
        open = true,
        reload = true,
        args = function(ctx)
          local template = vim.fn.stdpath "config" .. "/templates/preview-style.html"
          return {
            "-f",
            "rst",
            ctx.file,
            "-s",
            "--katex",
            "--no-highlight",
            "-o",
            ctx.output,
            "--template",
            template,
          }
        end,
        output = function(ctx)
          return "/tmp/" .. vim.fn.fnamemodify(ctx.file, ":t:r") .. ".html"
        end,
      },
    }

    local group = vim.api.nvim_create_augroup("PreviewLiveMarkdown", { clear = true })
    local timer = assert(vim.uv.new_timer())
    local template = vim.fn.stdpath "config" .. "/templates/preview-style.html"

    local function refresh(bufnr)
      local ok, preview = pcall(require, "preview")
      if not ok then
        return
      end
      local status = preview.status(bufnr)
      if not (status and status.watching and status.output_file) then
        return
      end
      local out = status.output_file
      local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
      vim.system(
        {
          "pandoc",
          "-f",
          "gfm",
          "-s",
          "--katex",
          "--no-highlight",
          "-o",
          out,
          "--template",
          template,
        },
        { stdin = content },
        vim.schedule_wrap(function(res)
          if res.code ~= 0 then
            return
          end
          local reload = require "preview.reload"
          reload.inject(out)
          reload.broadcast()
        end)
      )
    end

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
      group = group,
      pattern = "*.md",
      callback = function(args)
        timer:stop()
        timer:start(
          300,
          0,
          vim.schedule_wrap(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
              refresh(args.buf)
            end
          end)
        )
      end,
    })
  end,
}
