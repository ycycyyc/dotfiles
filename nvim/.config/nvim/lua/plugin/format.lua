return {
  "stevearc/conform.nvim",
  lazy = true,
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black" },
    },
  },
}
