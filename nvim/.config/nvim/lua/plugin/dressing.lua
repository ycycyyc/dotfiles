local M = {
  initfuncs = {
    {
      "DressingSelect",
      function()
        YcVim.map.buf("n", "q", ":q<cr>")
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
    select = {
      builtin = {
        relative = "cursor",
        win_options = {
          winhighlight = "Normal:MyFloatNormal",
        },
      },
      backend = { "builtin" },
    },
    input = {
      win_options = {
        winhighlight = "Normal:MyFloatNormal",
      },
    },
  }

  YcVim.setup_m(M)
end

return M
