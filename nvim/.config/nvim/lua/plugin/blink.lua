local plugin = {
  "saghen/blink.cmp",
  dependencies = {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    lazy = true,

    config = function(_, opts)
      local luasnip = require "luasnip"

      ---@diagnostic disable: undefined-field
      luasnip.setup(opts)

      require("luasnip.loaders.from_vscode").lazy_load {
        paths = vim.fn.stdpath "config" .. "/snippets",
      }
    end,
  },
}

YcVim.cmp.snippet.try_stop = function()
  if
    require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
    and not require("luasnip").session.jump_active
  then
    local ls = require "luasnip"
    ls.unlink_current()
  end
end

plugin.opts = {
  keymap = {
    ["<cr>"] = { "select_and_accept", "fallback" },
    ["<c-y>"] = { "select_and_accept", "fallback" },
    ["<C-n>"] = { "select_next", "show", "fallback" },
    ["<C-e>"] = {
      function()
        require("blink.cmp").hide()
        YcVim.util.i_move_to_end()
      end,
    },
  },
  cmdline = { enabled = false },
  snippets = { preset = "luasnip" },
  completion = {
    menu = {
      border = "none",
      draw = {
        columns = { { "label", "label_description", gap = 2 }, { "kind_icon", "kind", gap = 2 } },
      },
    },
  },
}

if 1 == vim.fn.executable "cargo" then
  plugin.build = "cargo build --release"
else
  plugin.opts.fuzzy = { implementation = "lua" }
end

return plugin
