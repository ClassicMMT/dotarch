return {
  "mrcjkb/rustaceanvim",
  lazy = false,
  init = function()
    vim.g.rustaceanvim = {
      server = {
        cmd = { "lspmux", "client", "--server-path", "/usr/bin/rust-analyzer" },
        default_settings = {
          ["rust-analyzer"] = {
            checkOnSave = true,
            check = { command = "clippy" },
            cargo = { features = "all" },
          },
        },
      },
    }
  end,
}
