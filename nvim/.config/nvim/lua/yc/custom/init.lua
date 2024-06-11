return {
  setup = function()
    require("yc.custom.theme").setup()
    require("yc.custom.line").setup()
    require("yc.custom.lsp").setup()
    require("yc.custom.terminal").setup()
    require("yc.custom.gotags").setup()
  end,
}
