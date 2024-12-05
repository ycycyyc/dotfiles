local keys = require "basic.keys"
local helper = require "utils.helper"

local M = {
  keymaps = {
    {
      "n",
      keys.global_find_and_replace,
      function()
        vim.cmd "GrugFar"
      end,
      {},
    },

    {
      "n",
      keys.buffer_find_and_replace,
      function()
        require("grug-far").with_visual_selection { prefills = { paths = vim.fn.expand "%" } }
      end,
      {},
    },
  },
}

local opts = {
  keymaps = {
    replace = { n = ',r' },
    syncLine = { n = ',l' },
    syncLocations = { n = ',s' },
    qflist = { n = ",p" },
    close = { n = "<leader>q" },
    refresh = { n = ',f' },
  },
  resultsSeparatorLineChar = "-",
  icons = {
    enabled = false,
  },
}

M.config = function()
  require("grug-far").setup(opts)
  helper.setup_m(M)
end

return M
