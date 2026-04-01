return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  init = function()
    vim.g.no_plugin_maps = true
  end,
  lazy = false,

  -- https://github.com/saikocat/dotfiles/blob/master/neovim/.config/nvim/lua/plugins/code/treesitter_textobjects_keymaps.lua
  config = function()
    require("nvim-treesitter-textobjects").setup {
      move = {
        set_jumps = true,
      },
      select = {
        lookahead = true,
        selection_modes = {
          ["@parameter.outer"] = "v", -- charwise
          ["@function.outer"] = "V", -- linewise
          ["@class.outer"] = "<c-v>", -- blockwise
        },
        include_surrounding_whitespace = false,
      },
    }

    local map = function(modes, lhs, rhs, opts)
      opts = vim.tbl_extend("force", { silent = true, noremap = true }, opts or {})
      vim.keymap.set(modes, lhs, rhs, opts)
    end

    local select = require "nvim-treesitter-textobjects.select"
    local move = require "nvim-treesitter-textobjects.move"

    local sel = function(capture, group)
      return function()
        select.select_textobject(capture, group or "textobjects")
      end
    end

    local mv = function(method, capture, group)
      return function()
        move[method](capture, group or "textobjects")
      end
    end

    local action_maps = {
      { { "x", "o" }, "af", sel "@function.outer", { desc = "TS: around function" } },
      { { "x", "o" }, "if", sel "@function.inner", { desc = "TS: inside function" } },

      { { "n", "x", "o" }, "[f", mv("goto_previous_start", "@function.outer"), { desc = "TS: prev function start" } },
      { { "n", "x", "o" }, "]f", mv("goto_next_start", "@function.outer"), { desc = "TS: next function start" } },
    }

    for _, m in ipairs(action_maps) do
      map(m[1], m[2], m[3], m[4])
    end
  end,
}
