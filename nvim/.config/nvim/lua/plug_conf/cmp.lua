local M = {}

local symbol_map = {
  Text = "λ",
  Method = "➜",
  Function = "ƒ",
  Constructor = "◌",
  Field = "●",
  Variable = "⚙",
  Class = "C",
  Interface = "I",
  Module = "▸",
  Property = "➜",
  Unit = "U",
  Value = "V",
  Enum = "ℰ",
  Keyword = "𝙆",
  Snippet = "S",
  Color = "C",
  File = "F",
  Reference = "r",
  Folder = "f",
  EnumMember = "✓",
  Constant = "c",
  Struct = "𝓢",
  Event = "🗲",
  Operator = "+",
  TypeParameter = "𝙏",
}

M.config = function()
  local cmp = require "cmp"
  local tool = require "utils.helper"
  local lspkind = require "lspkind"
  vim.o.completeopt = "menu,menuone,noselect"

  cmp.setup {
    -- completion = {
    --     autocomplete = true -- disable auto-completion.
    -- },
    -- preselect = 'disable',
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- local luasnip = require('luasnip')
        -- if not luasnip then
        --     print("luasnip not found")
        --     return
        -- end
        -- luasnip.lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },

    mapping = {
      -- ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
      -- ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
      ["<C-e>"] = cmp.mapping {
        i = tool.i_move_to_end,
      },
      ["<C-k>"] = cmp.mapping {
        i = function()
          if cmp.visible() then
            -- require("notify")("visible")
            cmp.abort()
          else
            -- require("notify")("not visible")
            cmp.complete()
          end
        end,
        c = function()
          if cmp.visible() then
            -- require("notify")("visible")
            cmp.close()
          else
            -- require("notify")("not visible")
            cmp.complete()
          end
        end,
      },

      ["<c-n>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
        end
      end, { "i", "s" }),

      ["<c-p>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      -- ['<C-d>'] = cmp.mapping({i = cmp.mapping.abort(), c = cmp.mapping.close()}),
      ["<CR>"] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },

    formatting = {
      format = lspkind.cmp_format {
        -- mode = 'symbol', -- show only symbol annotations
        with_text = true,
        maxwidth = 200, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)

        -- The function below will be called before any actual modifications from lspkind
        -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
        before = function(entry, vim_item)
          -- vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"
          vim_item.kind = string.format("%s  %s", symbol_map[vim_item.kind], vim_item.kind)
          vim_item.menu = ({ buffer = "[BUF]", nvim_lsp = "[LSP]", luasnip = "[LS]", nvim_lua = "[Lua]" })[entry.source.name]
          return vim_item
        end,
      },
    },

    experimental = {
      ghost_text = false, -- this feature conflict to the copilot.vim's preview.
    },

    sources = cmp.config.sources({
      { name = "nvim_lua" },
      { name = "nvim_lsp" },
      { name = "vsnip" }, -- For vsnip users.
      -- {name = 'luasnip'} -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, { { name = "buffer" } }),
  }

  -- Set configuration for specific filetype.
  cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
      { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
    }, { { name = "buffer" } }),
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  -- cmp.setup.cmdline('/', {sources = {{name = 'buffer'}}})

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  -- cmp.setup.cmdline(':', {sources = cmp.config.sources({{name = 'path'}}, {{name = 'cmdline'}})})

  local cmp_autopairs = require "nvim-autopairs.completion.cmp"
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
end

return M
