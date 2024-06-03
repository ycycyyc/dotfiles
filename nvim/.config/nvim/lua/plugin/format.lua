local M = {}

M.config = function()
  require("conform").setup {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black" },
    },
  }
end

return M
