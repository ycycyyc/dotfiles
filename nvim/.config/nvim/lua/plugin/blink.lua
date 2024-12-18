local plugin = {
  "saghen/blink.cmp",
}

if 1 == vim.fn.executable "cargo" then
  plugin.build = "cargo build --release"
end

local hide = function(cmp)
  cmp.hide()
end

local toggle = function(cmp)
  if cmp.is_visible() then
    cmp.hide()
  else
    cmp.show()
  end
end

plugin.config = function()
  local opts = {
    keymap = {
      ["<cr>"] = { "select_and_accept", "fallback" },
      ["<C-k>"] = { toggle },
      ["<Tab>"] = { hide, "snippet_forward", "fallback" },
      ["<S-Tab>"] = { hide, "snippet_backward", "fallback" },
      ["<C-e>"] = {
        function()
          require("blink.cmp").hide()
          require("utils.helper").i_move_to_end()
        end,
      },
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

return plugin
