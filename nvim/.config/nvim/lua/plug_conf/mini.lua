local keys = require "basic.keys"
local helper = require "utils.helper"

local buf_map = function(mode, key, action)
  vim.keymap.set(mode, key, action, { noremap = true, buffer = true, silent = true, nowait = true })
end

local minifiles_toggle = function(...)
  local minifiles = require "mini.files"
  if not minifiles.close() then
    minifiles.open(...)
  end
end

local open_current = function()
  local minifiles = require "mini.files"
  minifiles.open(vim.api.nvim_buf_get_name(0))
  minifiles.reveal_cwd()
end

local M = {
  keymaps = {
    { "n", keys.toggle_dir, minifiles_toggle, {} },
    { "n", keys.toggle_dir_open_file, open_current, {} },
  },
  initfuncs = {
    "minifiles",
    function()
      buf_map("n", "<c-j>", "<down>")
      buf_map("n", "<c-k>", "<up>")
      buf_map("n", "<cr>", function()
        local minifiles = require "mini.files"
        minifiles.go_in { close_on_file = true }
      end)
    end,
  },
}

M.config = function()
  require("mini.files").setup {
    mappings = {
      close = "q",
      go_in = "<c-l>",
      -- go_in_plus = "L",
      go_out = "<c-h>",
      -- go_out_plus = "H",
      reset = "<bs>",
      reveal_cwd = "@",
      show_help = "g?",
      synchronize = "<leader>w",
      trim_left = "<",
      trim_right = ">",
    },
    windows = {
      preview = true,
      width_focus = 25,
      width_nofocus = 25,
      width_preview = 25,
    },
    content = {
      prefix = function(fs_entry)
        -- if fs_entry.fs_type == "directory" then
        --   return "▸ ", "MiniFilesDirectory"
        -- end
      end,
    },
  }

  helper.setup_m(M)
end

return M
