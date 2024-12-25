local keys = YcVim.keys

local plugin = {}

plugin.opts = {
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

plugin.keymaps = {
  {
    "c",
    "<c-g>",
    function()
      require("flash").toggle()
    end,
    {},
  },
}

return {
  "folke/flash.nvim",
  keys = {
    { "/" },
    { "?" },
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
  config = function()
    require("flash").setup(plugin.opts)
    YcVim.setup(plugin)
  end,
}
