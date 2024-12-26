return {
  "stevearc/aerial.nvim",
  keys = {
    { YcVim.keys.toggle_symbol, "<cmd>AerialToggle<CR>" },
  },
  opts = {
    filter_kind = {
      "Class",
      "Constructor",
      "Enum",
      "Function",
      "Interface",
      "Module",
      "Method",
      "Struct",
    },
  },
}
