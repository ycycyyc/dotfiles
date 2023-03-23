-- init.lua
local M = {}

M.config = function()
  local helper = require "utils.helper"

  local symbols = {
    File = { icon = "file:", hl = "TSURI" },
    Module = { icon = "module:", hl = "TSNamespace" },
    Namespace = { icon = "ns:", hl = "TSNamespace" },
    Package = { icon = "package:", hl = "TSNamespace" },
    Class = { icon = "Class:", hl = "TSType" },
    Method = { icon = "ƒ", hl = "TSMethod" },
    Property = { icon = "Property:", hl = "TSMethod" },
    Field = { icon = "  field:", hl = "TSField" },
    Constructor = { icon = "Constructor:", hl = "TSConstructor" },
    Enum = { icon = "ℰ", hl = "TSType" },
    Interface = { icon = "Interface:", hl = "TSType" },
    Function = { icon = "func:", hl = "TSFunction" },
    Variable = { icon = "var:", hl = "TSConstant" },
    Constant = { icon = "const:", hl = "TSConstant" },
    String = { icon = "𝓐", hl = "TSString" },
    Number = { icon = "#", hl = "TSNumber" },
    Boolean = { icon = "⊨", hl = "TSBoolean" },
    Array = { icon = "Array:", hl = "TSConstant" },
    Object = { icon = "⦿", hl = "TSType" },
    Key = { icon = "🔐", hl = "TSType" },
    Null = { icon = "NULL", hl = "TSType" },
    EnumMember = { icon = "EnumMember:", hl = "TSField" },
    Struct = { icon = "𝓢", hl = "TSType" },
    Event = { icon = "🗲", hl = "TSType" },
    Operator = { icon = "+", hl = "TSOperator" },
    TypeParameter = { icon = "𝙏", hl = "TSParameter" },
  }

  local opt = {
    highlight_hovered_item = false,
    auto_unfold_hover = false,
    show_guides = true,
    auto_preview = false,
    position = "right",
    width = 35,
    show_numbers = true,
    show_relative_numbers = true,
    show_symbol_details = true,
    fold_markers = { "▸", "▾" },
    keymaps = {
      close = { "<Esc>", "q" },
      goto_location = "<Cr>",
      focus_location = "o",
      hover_symbol = "<C-space>",
      toggle_preview = "K",
      rename_symbol = "r",
      code_actions = "a",
      fold = "h",
      unfold = "l",
      fold_all = "W",
      unfold_all = "E",
      fold_reset = "R",
    },
    lsp_blacklist = {},
    symbol_blacklist = {},
    symbols = symbols,
  }

  require("symbols-outline").setup(opt)

  local map = helper.build_keymap { noremap = true }
  local keys = require "basic.keys"
  map({ "n", "v" }, keys.toggle_symbol, function()
    require("symbols-outline").toggle_outline()
    -- require'plug_conf.t_win'.refresh_theme()
  end)
end

return M
