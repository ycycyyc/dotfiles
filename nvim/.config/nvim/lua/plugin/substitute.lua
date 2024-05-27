local helper = require "utils.helper"

local M = {
  keymaps = {
    {
      "n",
      "<leader>x",
      function()
        require("substitute.exchange").operator()
      end,
      { noremap = true },
    },
    {
      "x",
      "X",
      function()
        require("substitute.exchange").visual()
      end,
      { noremap = true },
    },
    {
      "n",
      "<leader>xc",
      function()
        require("substitute.exchange").cancel()
      end,
      { noremap = true },
    },
  },
}

M.config = function()
  require("substitute").setup {
    exchange = {
      motion = false,
      use_esc_to_cancel = false,
    },
  }
  helper.setup_m(M)
end

return M
