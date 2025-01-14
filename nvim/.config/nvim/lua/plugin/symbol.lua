return {
  "hedyhli/outline.nvim",
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    { YcVim.keys.toggle_symbol, "<cmd>Outline<CR>" },
  },
  opts = {
    guides = {
      enabled = false,
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
    symbol_folding = {
      auto_unfold_hover = false,
      markers = { "▸", "▾" },
    },
  },
}
