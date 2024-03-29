return {
  ft = { "lua", "python" },
  config = function()
    require("formatter").setup {
      logging = false,
      log_level = vim.log.levels.WARN,
      filetype = {
        lua = {
          require("formatter.filetypes.lua").stylua,
        },
        python = {
          require("formatter.filetypes.python").black,
        },
      },
    }

    vim.api.nvim_del_user_command "Format"
    vim.api.nvim_del_user_command "FormatLock"
    vim.api.nvim_del_user_command "FormatWriteLock"
  end,
}
