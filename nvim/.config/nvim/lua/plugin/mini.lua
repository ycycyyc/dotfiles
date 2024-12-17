local keys = YcVim.keys


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
    {
      "minifiles",
      function()
        YcVim.map.buf("n", "<c-j>", "<down>")
        YcVim.map.buf("n", "<c-k>", "<up>")
        YcVim.map.buf("n", "<cr>", function()
          local minifiles = require "mini.files"
          minifiles.go_in { close_on_file = true }
        end)
      end,
    },
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

  YcVim.setup_m(M)
end

return M
