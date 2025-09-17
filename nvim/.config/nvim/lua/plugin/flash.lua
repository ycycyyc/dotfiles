local keys = YcVim.keys

return {
  "folke/flash.nvim",
  keys = {
    { "/" },
    { "?" },
    {
      "<c-g>",
      function()
        require("flash").toggle()
      end,
      mode = "c",
    },
    {
      keys.jump,
      function()
        require("flash").jump {
          label = {
            after = false, ---@type boolean|number[]
            before = true, -- before = { 0, 0 },
          },
        }
      end,
    },
    {
      keys.select_ts,
      function()
        require("flash").treesitter {
          actions = {
            ["<bs>"] = "prev",
          },
        }
      end,
    },
  },

  opts = {
    modes = {
      -- f t F T  ...
      char = { enabled = false },
      -- 开启/ ？查询
      search = { enabled = true },
    },
    label = {
      after = false, ---@type boolean|number[]
      -- before = { 0, 0 }, ---@type boolean|number[]
      before = true,
    },
    treesitter = { labels = "asdfghjklqwertyuiopzxcvbnm" },
    highlight = { backdrop = false },
  },
}
