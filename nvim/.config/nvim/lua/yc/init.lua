return {
  setup = function()
    require("basic.env").setup()
    require("yc.opt").setup()
    require("yc.map").setup() -- 必须先map，然后再加载lazy_plug
    require("yc.lazy_plug").setup()
    require("yc.theme").setup()
    require("yc.settings").setup()
  end,
}
