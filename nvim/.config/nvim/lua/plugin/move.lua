local M = {}

-- remove leap plugin
M.config = function()
  local helper = require "utils.helper"
  local keys = require "basic.keys"
  local nnoremap = helper.nnoremap()
  -- nnoremap(keys.jump , tool.cmd_func "HopChar2MW")

  -- require('leap').leap { target_windows = vim.tbl_filter(
  --   function (win) return vim.api.nvim_win_get_config(win).focusable end,
  --   vim.api.nvim_tabpage_list_wins(0)
  -- )}

  -- require('leap').add_default_mappings()
  --

  -- stylua: ignore
  require("leap").opts.labels = {
    "f", "j", "k", "o", "i", "m", "v", "e", "l", "d", "w", "u", "g", "n", "h", "s", "r", ";", "t",
    "y", "b", "c", ",", "x", "a", "F", "L", "M", "H", "N", "E", "B", "G", "z", "q", "p", "D", "J",
    "I", "Y", "R", "A", "Q", "T"
  }

  local jump = function()
    require("leap").leap {
      target_windows = vim.tbl_filter(function(win)
        return vim.api.nvim_win_get_config(win).focusable
      end, vim.api.nvim_tabpage_list_wins(0)),
    }
  end
  nnoremap(keys.jump, jump)
end

return M
