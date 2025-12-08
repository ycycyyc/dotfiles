---@type YcVim.SetupOpt
local setup = {}

setup.user_cmds = {
  {
    "SnacksShowHistory",
    ":lua Snacks.notifier.show_history()<cr>",
    {},
  },
}

local init = function()
  YcVim.setup(setup)

  local snacks = require "snacks"
  snacks.config.style("notification", { wo = { winblend = 0 } }) -- 避免notifier和代码重叠

  vim.keymap.set("n", YcVim.keys.toggle_term, function()
    snacks.terminal.toggle(nil, {
      win = {
        on_buf = function(win)
          vim.keymap.set("t", YcVim.keys.toggle_term, function()
            snacks.terminal.toggle()
          end, { buffer = win.buf, nowait = true })
        end,
        border = "rounded",
        position = "float",
        backdrop = 100,
        width = 0.85,
        height = 0.8,
        wo = { winhighlight = "Normal:Normal" },
      },
    })

    vim.defer_fn(function()
      vim.api.nvim_exec_autocmds("User", { pattern = "LineRefresh" })
    end, 0)
  end)
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = {
      win = {
        relative = "cursor",
        row = -3,
        col = 0,
        keys = {
          i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i" },
        },
      },
      icon = ">",
    },
    notifier = {
      enabled = true,
      padding = false,
      icons = {
        error = "E ",
        warn = "W ",
        info = "I ",
        debug = "E ",
        trace = "T ",
      },
      margin = { top = 1, right = 1, bottom = 1 },
    },
  },
  init = init,
}
