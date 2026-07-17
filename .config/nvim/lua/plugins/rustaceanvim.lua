return {
  "mrcjkb/rustaceanvim",
  lazy = false,
  init = function()
    vim.g.rustaceanvim = {
      server = {
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
