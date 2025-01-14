return {
  "MagicDuck/grug-far.nvim",
  keys = {
    {
      YcVim.keys.global_find_and_replace,
      function()
        require("grug-far").open { prefills = { search = vim.fn.expand "<cword>", flags = "--fixed-strings" } }
      end,
    },
    {
      YcVim.keys.buffer_find_and_replace,
      function()
        require("grug-far").open {
          prefills = { search = vim.fn.expand "<cword>", paths = vim.fn.expand "%v", flags = "--fixed-strings" },
        }
      end,
    },
  },
  opts = {
    keymaps = {
      replace = { n = ",r" },
      syncLine = { n = ",l" },
      syncLocations = { n = ",s" },
      qflist = { n = ",p" },
      close = { n = "q" },
      refresh = { n = ",f" },
    },
  },
}
