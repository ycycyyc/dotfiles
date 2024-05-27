local keys = require "basic.keys"
local helper = require "utils.helper"

local buf_map = function(mode, key, action)
  vim.keymap.set(mode, key, action, { noremap = true, buffer = true, silent = true })
end

local M = {
  keymaps = {
    {
      "n",
      keys.git_diff_file,
      function()
        local file = vim.fn.expand "%:~:."
        vim.cmd("DiffviewFileHistory " .. file)
      end,
      {},
    },
    {
      "n",
      keys.git_diff_open,
      ":DiffviewOpen<cr>",
      {},
    },
  },
  initfuncs = {
    {
      { "DiffviewFiles", "DiffviewFileHistory" },
      function()
        local close = function()
          vim.cmd "DiffviewClose"
          vim.cmd "silent! checktime"
        end

        buf_map("n", "<leader>q", close)
        buf_map("n", "q", close)
        buf_map("n", "<esc>", close)
      end,
    },
  },
}

M.config = function()
  local opt = require "plugin.gitdiff_opt"
  require("diffview").setup(opt)

  helper.setup_m(M)
end

return M
