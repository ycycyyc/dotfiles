local M = {}

local white = 145
local bg = 239
local blue = 39
local red = 204
local yellow = 180
local purple = 170
local cyan = 38
local green = 114
local black = 235

M.opts = {
  include_buftypes = { "", "nowrite", "nofile" },
  create_autocmd = false,
  modifiers = {
    ---Filename modifiers applied to dirname.
    ---
    ---See: `:help filename-modifiers`
    ---
    ---@type string
    dirname = ":~:.",

    ---Filename modifiers applied to basename.
    ---
    ---See: `:help filename-modifiers`
    ---
    ---@type string
    basename = "",
  },

  theme = {
    normal = { ctermbg = bg },
    dirname = { bold = true, ctermfg = white, ctermbg = bg },
    basename = { bold = true, ctermfg = black, ctermbg = green },
    modified = { bold = true, ctermfg = red },
    context_method = { bold = false, ctermfg = blue, ctermbg = bg },
    context_function = { bold = true, ctermfg = blue, ctermbg = bg },
    context_field = { bold = false, ctermfg = red, ctermbg = bg },
    context_struct = { bold = false, ctermfg = yellow, ctermbg = bg },
    context_namespace = { bold = false, ctermfg = red, ctermbg = bg },
    context_class = { bold = false, ctermfg = yellow, ctermbg = bg },
    context_enum = { bold = false, ctermfg = yellow, ctermbg = bg },
    context_constructor = { bold = false, ctermfg = blue, ctermbg = bg },
    context_constant = { bold = false, ctermfg = cyan, ctermbg = bg },
    context_variable = { bold = false, ctermfg = white, ctermbg = bg },
    context_interface = { bold = false, ctermfg = yellow, ctermbg = bg },
    context_object = { bold = false, ctermfg = red, ctermbg = bg },

    context_file = { fg = "#ac8fe4" },
    context_module = { fg = "#ac8fe4" },
    context_package = { fg = "#ac8fe4" },
    context_property = { fg = "#ac8fe4" },
    context_string = { fg = "#ac8fe4" },
    context_number = { fg = "#ac8fe4" },
    context_boolean = { fg = "#ac8fe4" },
    context_array = { fg = "#ac8fe4" },
    context_key = { fg = "#ac8fe4" },
    context_null = { fg = "#ac8fe4" },
    context_enum_member = { fg = "#ac8fe4" },
    context_event = { fg = "#ac8fe4" },
    context_operator = { fg = "#ac8fe4" },
    context_type_parameter = { fg = "#ac8fe4" },
  },

  symbols = {
    ---Modification indicator.
    ---
    ---@type string
    modified = "[+]",

    ---Truncation indicator.
    ---
    ---@type string
    ellipsis = "…",

    ---Entry separator.
    ---
    ---@type string
    separator = "▸",
  },
  context_follow_icon_color = true,
  lead_custom_section = function()
    return { { " %{winnr()} ", "StatusLineWinnr" }, { " ", "StatusLineNormal" } }
  end,

  show_modified = true,
  show_dirname = true,

  kinds = {
    File = "file:",
    Module = "module:",
    Namespace = "",
    Package = "package:",
    Class = "",
    Method = "",
    Property = "property:",
    Field = "",
    Constructor = "",
    Enum = "",
    Interface = "",
    Function = "",
    Variable = "",
    Constant = "",
    String = "str:",
    Number = "number:",
    Boolean = "bool:",
    Array = "arr:",
    Object = "",
    Key = "key:",
    Null = "null:",
    EnumMember = "",
    Struct = "",
    Event = "event:",
    Operator = "",
    TypeParameter = "",
  },
}

M.config = function()
  local helper = require "utils.helper"
  vim.api.nvim_create_autocmd({
    helper.since_nvim(0, 9) and "WinResized" or "WinScrolled",
    "BufWinEnter",
    "CursorHold",
    "InsertLeave",

    -- include this if you have set `show_modified` to `true`
    "BufModifiedSet",
  }, {
    group = vim.api.nvim_create_augroup("barbecue.updater", {}),
    callback = function()
      require("barbecue.ui").update()
    end,
  })

  require("barbecue").setup(M.opts)
end

return M
