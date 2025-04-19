return {
  "stevearc/conform.nvim",
  lazy = true,
  init = function()
    YcVim.lsp.action.plugin_format = function()
      require("conform").format { bufnr = 0 }
    end
  end,
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black" },
    },
  },
}
