local helper = require "utils.helper"

local buf_map = function(mode, key, action)
  vim.keymap.set(mode, key, action, { noremap = true, buffer = true, silent = true })
end

local M = {
  initfuncs = {
    {
      "DressingSelect",
      function()
        buf_map("n", "q", ":q<cr>")
      end,
    },
  },
}

M.init = function()
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.select = function(...)
    require("lazy").load { plugins = { "dressing.nvim" } }
    return vim.ui.select(...)
  end
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.input = function(...)
    require("lazy").load { plugins = { "dressing.nvim" } }
    return vim.ui.input(...)
  end
end

M.config = function()
  require("dressing").setup {
    select = { backend = { "builtin" } },
  }

  helper.setup_m(M)
end

return M
