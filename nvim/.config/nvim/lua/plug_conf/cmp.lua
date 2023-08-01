local M = {}

M.config = function()
  local cmp = require "cmp"
  local tool = require "utils.helper"
  vim.o.completeopt = "menu,menuone,noselect"

  local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
  end

  cmp.setup {
    snippet = {
      expand = function(args)
        local luasnip = require "luasnip"
        luasnip.lsp_expand(args.body)
      end,
    },

    mapping = {
      ["<C-e>"] = cmp.mapping {
        i = tool.i_move_to_end,
      },
      ["<C-k>"] = cmp.mapping {
        i = function()
          if cmp.visible() then
            cmp.abort()
          else
            cmp.complete()
          end
        end,
        c = function()
          if cmp.visible() then
            cmp.close()
          else
            cmp.complete()
          end
        end,
      },

      ["<c-n>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<c-p>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<C-y>"] = cmp.config.disable,
      ["<CR>"] = cmp.mapping.confirm { select = true },
    },

    sources = cmp.config.sources({
      { name = "nvim_lua", max_item_count = 10, keyword_length = 2 },
      { name = "nvim_lsp", max_item_count = 10, keyword_length = 2 },
      { name = "luasnip", max_item_count = 10, keyword_length = 2 }, -- For snip users.
    }, { { name = "buffer" } }),
  }
end

return M
