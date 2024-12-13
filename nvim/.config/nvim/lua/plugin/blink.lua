local M = {}

local tool = require "utils.helper"

M.config = function()
  local hide = function(cmp)
    cmp.hide()
  end

  vim.keymap.set({ "i", "s" }, "<c-e>", function()
    require("blink.cmp").hide()
    tool.i_move_to_end "move to line end"
  end, { noremap = true })

  local opts = {
    keymap = {
      ["<cr>"] = { "select_and_accept", "fallback" },
      ["<C-k>"] = {
        function(cmp)
          if cmp.is_visible() then
            cmp.hide()
          else
            cmp.show()
          end
        end,
      },
      ["<Tab>"] = { hide, "snippet_forward", "fallback" },
      ["<S-Tab>"] = { hide, "snippet_backward", "fallback" },
      ["<C-e>"] = {},
    },
    sources = {
      default = { "lsp", "path", "buffer" },
      cmdline = {},
    },
    completion = {
      menu = {
        draw = {
          columns = { { "label", "label_description", gap = 1 }, { "kind" } },
        },
      },
    },
    fuzzy = {
      prebuilt_binaries = {
        download = true,
      },
    },
  }

  require("blink.cmp").setup(opts)
end

return M
