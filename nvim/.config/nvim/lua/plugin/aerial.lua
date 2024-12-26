---@type table<string, string[]|boolean>?
local kind_filter = {
  default = {
    "Class",
    "Constructor",
    "Enum",
    "Field",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Namespace",
    "Package",
    "Property",
    "Struct",
    "Trait",
  },
  markdown = false,
  help = false,
  -- you can specify a different filter for each filetype
  lua = {
    "Class",
    "Constructor",
    "Enum",
    "Field",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Namespace",
    -- "Package", -- remove package since luals uses it for control flow structures
    "Property",
    "Struct",
    "Trait",
  },
}

local filter_kind = assert(vim.deepcopy(kind_filter))
filter_kind._ = filter_kind.default
filter_kind.default = nil

return {
  "stevearc/aerial.nvim",
  keys = {
    { YcVim.keys.toggle_symbol, "<cmd>AerialToggle<CR>" },
  },
  opts = {
    attach_mode = "global",
    backends = { "lsp", "treesitter", "markdown", "man" },
    show_guides = true,
    layout = {
      resize_to_content = false,
      min_width = 70,
      win_opts = {
        winhl = "Normal:MyFloatNormal,FloatBorder:MyFloatNormal,SignColumn:SignColumnSB",
        signcolumn = "yes",
        statuscolumn = " ",
      },
    },
    filter_kind = filter_kind,
    guides = {
      mid_item = "├╴",
      last_item = "└╴",
      nested_top = "│ ",
      whitespace = "  ",
    },
  },
}
