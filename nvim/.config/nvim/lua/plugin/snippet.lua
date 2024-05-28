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
    -- 真正用到snippet plugin的时候才加载比如tab s-tab expand
    -- 如果不太合适, 可以在插入时加载
    -- event = "InsertEnter",
    lazy = true,
    cond = false,
    -- config = function()
    -- require("plugin.luasnip").init_snippets()
    -- end,
  },
  init = function()
    -- copy from: https://github.com/tjdevries/config.nvim/blob/master/lua/custom/snippets.lua

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.snippet.expand = function(input)
      local ls = require "luasnip"
      ls.lsp_expand(input)
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.snippet.active = function(filter)
      local ls = require "luasnip"
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
      local ls = require "luasnip"
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

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.snippet.stop = function()
      local ls = require "luasnip"
      ls.unlink_current()
    end
  end,
}

local snippy = {
  plugin = {
    "dcampos/nvim-snippy",
    dependencies = {
      "dcampos/cmp-snippy",
    },
    lazy = true,
    cond = false,
  },
  init = function()
    vim.snippet.expand = function(input)
      local sn = require "snippy"
      sn.expand_snippet(input)
    end

    vim.snippet.active = function(filter)
      local sn = require "snippy"
      return sn.can_jump(filter.direction)
    end

    vim.snippet.jump = function(direction)
      local sn = require "snippy"
      if direction > 0 then
        sn.next()
      else
        sn.previous()
      end
    end
  end,
}

local native = {
  init = function()
    local expand = vim.snippet.expand

    vim.snippet.expand = function(input)
      local is_snippet = string.match(input, "%$")
      if is_snippet then
        expand(input)
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
    event = "InsertEnter", -- TODO vim插件，没法做到用的时候再加载
    cond = false,
  },

  init = function()
    vim.snippet.expand = function(input)
      vim.fn["vsnip#anonymous"](input)
    end

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
    engine.init()
  else
    engine.plugin.cond = true
    engine.plugin.init = engine.init
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
