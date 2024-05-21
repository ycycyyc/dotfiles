local M = {}

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
  local keys = require "basic.keys"
  local minifiles = require "mini.files"
  local add_filetypes_initfunc = require("yc.settings").add_filetypes_initfunc

  local minifiles_toggle = function(...)
    if not minifiles.close() then
      minifiles.open(...)
    end
  end

  local open_current = function()
    minifiles.open(vim.api.nvim_buf_get_name(0))
    minifiles.reveal_cwd()
  end

  vim.keymap.set("n", keys.toggle_dir, minifiles_toggle)
  vim.keymap.set("n", keys.toggle_dir_open_file, open_current)

  add_filetypes_initfunc("minifiles", function()
    local opt = { noremap = true, buffer = true, silent = true, nowait = true }

    vim.keymap.set("n", "<cr>", function()
      minifiles.go_in { close_on_file = true }
    end, opt)

    vim.keymap.set("n", "<c-j>", "<down>", opt)
    vim.keymap.set("n", "<c-k>", "<up>", opt)
  end)
end

return M
