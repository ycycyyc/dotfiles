-- init.lua
local M = {}

M.config = function()
  local opt = {
    guides = {
      enabled = false,
    },
    keymaps = {
      close = { "<Esc>", "q" },
      code_actions = "a",
      fold = "h",
      fold_all = "W",
      fold_toggle = "o",
      fold_reset = "R",
      goto_location = "<Cr>",
      hover_symbol = "<C-space>",
      peek_location = "<cr>",
      rename_symbol = "r",
      toggle_preview = "p",
      unfold = "l",
      unfold_all = "E",
    },
    outline_items = {
      highlight_hovered_item = false,
      show_symbol_details = true,
    },
    outline_window = {
      position = "right",
      show_numbers = true,
      show_relative_numbers = true,
      width = 35,
    },
    preview_window = {
      auto_preview = false,
    },
    provider = {
      lsp = {
        blacklist_clients = {},
      },
    },
    symbol_folding = {
      auto_unfold_hover = false,
      markers = { "▸", "▾" },
    },
    symbols = {
      filter = {
        -- exclude = true,
      },
      icons = {
        Array = {
          hl = "@constant",
          icon = "Array:",
        },
        Boolean = {
          hl = "TSBoolean",
          icon = "⊨",
        },
        Class = {
          hl = "@type",
          icon = "Class:",
        },
        Constant = {
          hl = "@constant",
          icon = "const:",
        },
        Constructor = {
          hl = "@constructor",
          icon = "Constructor:",
        },
        Enum = {
          hl = "@type",
          icon = "ℰ",
        },
        EnumMember = {
          hl = "@field",
          icon = "EnumMember:",
        },
        Event = {
          hl = "@type",
          icon = "🗲",
        },
        Field = {
          hl = "@field",
          icon = "  field:",
        },
        File = {
          hl = "@text.uri",
          icon = "file:",
        },
        Function = {
          hl = "@function",
          icon = "func:",
        },
        Interface = {
          hl = "@type",
          icon = "Interface:",
        },
        Key = {
          hl = "@type",
          icon = "🔐",
        },
        Method = {
          hl = "@method",
          icon = "ƒ",
        },
        Module = {
          hl = "@namespace",
          icon = "module:",
        },
        Namespace = {
          hl = "@namespace",
          icon = "ns:",
        },
        Null = {
          hl = "@type",
          icon = "NULL",
        },
        Number = {
          hl = "@number",
          icon = "#",
        },
        Object = {
          hl = "@type",
          icon = "⦿",
        },
        Operator = {
          hl = "@operator",
          icon = "+",
        },
        Package = {
          hl = "@namespace",
          icon = "package:",
        },
        Property = {
          hl = "@method",
          icon = "Property:",
        },
        String = {
          hl = "@string",
          icon = "𝓐",
        },
        Struct = {
          hl = "@type",
          icon = "𝓢",
        },
        TypeParameter = {
          hl = "@parameter",
          icon = "𝙏",
        },
        Variable = {
          hl = "@constant",
          icon = "var:",
        },
      },
    },
  }

  require("outline").setup(opt)
end

return M
