return {
  "MagicDuck/grug-far.nvim",
  keys = {
    {
      YcVim.keys.global_find_and_replace,
      ":GrugFar<cr>",
    },
    {
      YcVim.keys.buffer_find_and_replace,
      function()
        require("grug-far").with_visual_selection { prefills = { paths = vim.fn.expand "%" } }
      end,
    },
  },
  opts = {
    keymaps = {
      replace = { n = ",r" },
      syncLine = { n = ",l" },
      syncLocations = { n = ",s" },
      qflist = { n = ",p" },
      close = { n = "<leader>q" },
      refresh = { n = ",f" },
    },
    resultsSeparatorLineChar = "-",
    icons = {
      enabled = false,
    },
  },
}
