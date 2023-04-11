local M = {}

M.config = function(snip_dir)
  local cmp = require "cmp"
  local tool = require "utils.helper"
  vim.o.completeopt = "menu,menuone,noselect"

  cmp.setup {
    -- preselect = 'disable',
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        require("luasnip").lsp_expand(args.body)
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
      ["<CR>"] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },

    experimental = {
      ghost_text = false, -- this feature conflict to the copilot.vim's preview.
    },

    sources = cmp.config.sources({
      { name = "nvim_lua" },
      { name = "nvim_lsp" },
      { name = "luasnip" }, -- For snip users.
    }, { { name = "buffer" } }),
  }

  local cmp_autopairs = require "nvim-autopairs.completion.cmp"
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })

  local env = require("basic.env").env
  if env.luasnip then
    require("luasnip.loaders.from_vscode").lazy_load { paths = { snip_dir } }

    vim.keymap.set({ "i", "s" }, "<c-j>", function()
      require("luasnip").jump(1)
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
      require("luasnip").jump(-1)
    end, { silent = true })

    require "plug_conf.luasnip"
  end
end

return M
