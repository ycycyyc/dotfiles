local M = {}

local helper = require "utils.helper"

M.config = function()
  local hide = function(cmp)
    cmp.hide()
  end

  vim.keymap.set({ "i", "s" }, "<c-e>", function()
    require("blink.cmp").hide()
    helper.i_move_to_end "move to line end"
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
      ghost_text = {
        enabled = false,
      },
      menu = {
        draw = {
          columns = { { "label", "label_description", gap = 1 }, { "kind" } },
        },
      },
    },
    fuzzy = {
      prebuilt_binaries = {
        download = false,
      },
    },
  }

  require("blink.cmp").setup(opts)

  -- 在默认模式下按<c-n>或者<c-p>可以修改当前的word
  local list = require "blink.cmp.completion.list"
  local select = list.select
  list.select = function(idx, o)
    select(idx, o)
    local item = list.items[idx]
    require("blink.cmp.completion.trigger").suppress_events_for_callback(function()
      if idx and idx > 1 and item and list.config.selection == "preselect" then
        list.apply_preview(item)
      end
    end)
  end
end

return M
