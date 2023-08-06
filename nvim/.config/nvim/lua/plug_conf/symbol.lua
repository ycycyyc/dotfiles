-- init.lua
local M = {}

M.config = function()
  local helper = require "utils.helper"

  local symbols = {
    File = { icon = "file:", hl = "@text.uri" },
    Module = { icon = "module:", hl = "@namespace" },
    Namespace = { icon = "ns:", hl = "@namespace" },
    Package = { icon = "package:", hl = "@namespace" },
    Class = { icon = "Class:", hl = "@type" },
    Method = { icon = "ƒ", hl = "@method" },
    Property = { icon = "Property:", hl = "@method" },
    Field = { icon = "  field:", hl = "@field" },
    Constructor = { icon = "Constructor:", hl = "@constructor" },
    Enum = { icon = "ℰ", hl = "@type" },
    Interface = { icon = "Interface:", hl = "@type" },
    Function = { icon = "func:", hl = "@function" },
    Variable = { icon = "var:", hl = "@constant" },
    Constant = { icon = "const:", hl = "@constant" },
    String = { icon = "𝓐", hl = "@string" },
    Number = { icon = "#", hl = "@number" },
    Boolean = { icon = "⊨", hl = "TSBoolean" },
    Array = { icon = "Array:", hl = "@constant" },
    Object = { icon = "⦿", hl = "@type" },
    Key = { icon = "🔐", hl = "@type" },
    Null = { icon = "NULL", hl = "@type" },
    EnumMember = { icon = "EnumMember:", hl = "@field" },
    Struct = { icon = "𝓢", hl = "@type" },
    Event = { icon = "🗲", hl = "@type" },
    Operator = { icon = "+", hl = "@operator" },
    TypeParameter = { icon = "𝙏", hl = "@parameter" },
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
  map({ "n" }, keys.toggle_symbol, function()
    require("symbols-outline").toggle_outline()
  end)
end

return M
