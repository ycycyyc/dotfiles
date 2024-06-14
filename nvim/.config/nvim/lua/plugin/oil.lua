local keys = require "basic.keys"
local helper = require "utils.helper"

local buf_map = function(mode, key, action)
  vim.keymap.set(mode, key, action, { noremap = true, buffer = true, silent = true })
end

local M = {
  initfuncs = {
    {
      "oil",
      function()
        buf_map("n", "q", function()
          require("oil").close()
        end)
      end,
    },
  },
  keymaps = {
    {
      "n",
      keys.toggle_dir,
      function()
        require("oil").toggle_float()
      end,
      {},
    },
  },
}

M.config = function()
  require("oil").setup {
    default_file_explorer = false,
    keymaps = {
      ["<CR>"] = "actions.select",
      ["<c-l>"] = "actions.select",
      ["<c-h>"] = "actions.parent",
      ["<c-r>"] = "actions.open_cwd",
      ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
    },
    use_default_keymaps = false,
    win_options = {
      winhighlight = "Normal:LazyNormal",
    },
    float = {
      padding = 4,
      max_width = 200,
    },
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, _)
        return name == ".." or name == ".git"
      end,
    },
  }
  helper.setup_m(M)
end

return M
