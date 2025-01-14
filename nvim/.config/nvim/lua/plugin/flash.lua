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
        if YcVim.env.coc then
          vim.notify "neovim will panic"
          return -- TODO: 同时使用coc 和treesitter neovim会直接退出？
        end
        require("flash").treesitter()
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
