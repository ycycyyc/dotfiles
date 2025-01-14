local plugin = {
  "saghen/blink.cmp",
}

if 1 == vim.fn.executable "cargo" then
  plugin.build = "cargo build --release"
end

plugin.opts = {
  keymap = {
    ["<cr>"] = { "select_and_accept", "fallback" },
    ["<c-y>"] = { "select_and_accept", "fallback" },
    ["<C-n>"] = {
      function(cmp)
        if cmp.is_visible() then
          cmp.select_next()
          return true
        elseif YcVim.util.has_words_before() then
          cmp.show()
          return true
        end
      end,
      "fallback",
    },
    ["<C-e>"] = {
      function()
        require("blink.cmp").hide()
        YcVim.util.i_move_to_end()
      end,
    },
  },
  sources = {
    default = { "lsp", "path", "buffer" },
    cmdline = {},
  },
  completion = {
    menu = {
      draw = {
        columns = { { "label", "label_description", gap = 2 }, { "kind_icon", "kind", gap = 2 } },
      },
    },
  },
  fuzzy = {
    prebuilt_binaries = {
      download = false,
    },
  },
}

return plugin
