local snippet = require("basic.env").env.snippet

local M = {}

local luasnip = {
  plugin = {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
    },
    event = "InsertEnter",
    cond = false,
  },
  config = function()
    -- copy from: https://github.com/tjdevries/config.nvim/blob/master/lua/custom/snippets.lua
    local ls = require "luasnip"

    -- TODO: Think about `locally_jumpable`, etc.
    -- Might be nice to send PR to luasnip to use filters instead for these functions ;)
    vim.snippet.expand = ls.lsp_expand

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.snippet.active = function(filter)
      filter = filter or {}
      filter.direction = filter.direction or 1

      if filter.direction == 1 then
        return ls.expand_or_jumpable()
      else
        return ls.jumpable(filter.direction)
      end
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.snippet.jump = function(direction)
      if direction == 1 then
        if ls.expandable() then
          return ls.expand_or_jump()
        else
          return ls.jumpable(1) and ls.jump(1)
        end
      else
        return ls.jumpable(-1) and ls.jump(-1)
      end
    end

    vim.snippet.stop = ls.unlink_current
  end,
}

local snippy = {
  plugin = {
    "dcampos/nvim-snippy",
    dependencies = {
      "dcampos/cmp-snippy",
    },
    event = "InsertEnter",
    cond = false,
  },
  config = function()
    local sn = require "snippy"

    vim.snippet.expand = sn.expand_snippet

    vim.snippet.active = function(filter)
      return sn.can_jump(filter.direction)
    end

    vim.snippet.jump = function(direction)
      if direction > 0 then
        sn.next()
      else
        sn.previous()
      end
    end
  end,
}

local native = {
  config = function()
    local native_expand = vim.snippet.expand

    vim.snippet.expand = function(input)
      local is_snippet = string.match(input, "%$")
      if is_snippet then
        native_expand(input)
      else
        vim.api.nvim_put({ input }, "c", false, true)
      end
    end
  end,
}

local vsnip = {
  plugin = {
    "hrsh7th/vim-vsnip",
    dependencies = {
      "hrsh7th/cmp-vsnip",
    },
    event = "InsertEnter",
    cond = false,
  },

  config = function()
    vim.snippet.expand = vim.fn["vsnip#anonymous"]

    vim.snippet.active = function(filter)
      return vim.fn["vsnip#jumpable"](filter.direction) == 1
    end

    vim.snippet.jump = function(direction)
      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      if direction > 0 then
        feedkey("<Plug>(vsnip-jump-next)", "")
      else
        feedkey("<Plug>(vsnip-jump-prev)", "")
      end
    end
  end,
}

local all = {
  luasnip = luasnip,
  snippy = snippy,
  vsnip = vsnip,
  native = native,
}

M.init = function()
  local engine

  if not all[snippet] then
    snippet = "luasnip"
  end

  engine = all[snippet]
  if not engine.plugin then -- 比如native不需要依赖plugin直接调用配置参数
    engine.config()
  else
    engine.plugin.cond = true
    engine.plugin.config = engine.config
  end

  M.plugins = {}
  for _, se in pairs(all) do
    if se.plugin then
      table.insert(M.plugins, se.plugin)
    end
  end
end

M.init()

return M
