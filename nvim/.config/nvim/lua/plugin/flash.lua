local helper = require "utils.helper"
local keys = require "basic.keys"

local opts = {
  modes = {
    char = {
      enabled = false, -- f t F T  ...
    },
    search = {
      enabled = true, -- 开启/ ？查询
    },
  },
  label = {
    after = false, ---@type boolean|number[]
    -- before = { 0, 0 }, ---@type boolean|number[]
    before = true,
  },
  treesitter = {
    labels = "asdfghjklqwertyuiopzxcvbnm",
  },
  highlight = {
    backdrop = false,
  },
}

local M = {
  keymaps = {
    {
      "c",
      "<c-g>",
      function()
        require("flash").toggle()
      end,
      {},
      { lazy_load_ignore = true },
    },
    {
      "n",
      keys.jump,
      function()
        require("flash").jump {
          label = {
            after = false, ---@type boolean|number[]
            -- before = { 0, 0 },
            before = true,
          },
        }
      end,
      {},
    },
    {
      "n",
      keys.select_ts,
      function()
        require("flash").treesitter()
      end,
      {},
    },
  },
}

M.config = function()
  require("flash").setup(opts)
  helper.setup_m(M)
end

return M
