local vsnip = {
  "hrsh7th/vim-vsnip",
  dependencies = {
    "hrsh7th/cmp-vsnip",
  },
  event = "InsertEnter", -- TODO vim插件，没法做到用的时候再加载

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

local luasnip = {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  -- dependencies = {
  --   "saadparwaiz1/cmp_luasnip",
  -- },
  -- 真正用到snippet plugin的时候才加载比如tab s-tab expand
  -- 如果不太合适, 可以在插入时加载
  -- event = "InsertEnter",
  lazy = true,
  cond = true,
  config = function()
    -- Use the more sane snippet session leave logic. Copied from:
    -- https://github.com/L3MON4D3/LuaSnip/issues/258#issuecomment-1429989436
    -- vim.api.nvim_create_autocmd("ModeChanged", {
    --   pattern = "*",
    --   callback = function()
    --     if
    --       ((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
    --       and require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
    --       and not require("luasnip").session.jump_active
    --     then
    --       require("luasnip").unlink_current()
    --     end
    --   end,
    -- })
    -- or https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/configs/luasnip.lua#L13
  end,

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

    YcVim.cmp.snippet.try_stop = function()
      if
        require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
        and not require("luasnip").session.jump_active
      then
        local ls = require "luasnip"
        ls.unlink_current()
        -- vim.notify "stop luasnip"
      end
    end
  end,
}

local snippy = {
  "dcampos/nvim-snippy",
  lazy = true,
  init = function()
    vim.snippet.expand = function(input)
      local sn = require "snippy"
      sn.expand_snippet(input)
    end

    vim.snippet.active = function(filter)
      local sn = require "snippy"
      filter = filter or {}
      filter.direction = filter.direction or 1
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

    vim.snippet.stop = function() end
  end,
}

if YcVim.env.snippet == "native" then
  local expand = vim.snippet.expand
  vim.snippet.expand = function(input)
    -- Native sessions don't support nested snippet sessions.
    -- Always use the top-level session.
    -- Otherwise, when on the first placeholder and selecting a new completion,
    -- the nested session will be used instead of the top-level session.
    -- See: https://github.com/LazyVim/LazyVim/issues/3199
    local session = vim.snippet.active() and vim.snippet._session or nil

    local ok, err = pcall(expand, input)
    if not ok then
      vim.notify("Failed expand snippet:" .. input .. " got err:" .. err)
    end

    -- Restore top-level session when needed
    if session then
      vim.snippet._session = session
    end
  end

  return {}
end

local plugins = {
  luasnip = luasnip,
  vsnip = vsnip,
  snippy = snippy,
}

return plugins[YcVim.env.snippet]
