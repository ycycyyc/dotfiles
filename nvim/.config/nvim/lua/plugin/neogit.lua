local keys = require "basic.keys"
local helper = require "utils.helper"

local M = {
  keymaps = {
    {
      "n",
      keys.git_status,
      function()
        local neogit = require "neogit"
        neogit.open {}
      end,
      {},
    },
  },
}

M.config = function()
  require("neogit").setup {
    auto_refresh = false,
    auto_close_console = false,
    status = {
      mode_text = {
        M = "M",
        N = "N",
        D = "D",
        R = "R",
        A = "A",
      },
    },
    integrations = {
      fzf_lua = true,
    },
    mappings = {
      status = {},
    },
  }
  helper.setup_m(M)
end

return M
