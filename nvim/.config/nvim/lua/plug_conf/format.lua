return {
  config = function()
    require("formatter").setup {
      logging = false,
      log_level = vim.log.levels.WARN,
      filetype = {
        lua = {
          require("formatter.filetypes.lua").stylua,
        },
      },
    }
  end,
}
