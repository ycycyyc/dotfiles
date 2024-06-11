local keys = require "basic.keys"
local helper = require "utils.helper"

-- stylua: ignore
local M = {
  keymaps = {
    { "n", keys.dbg_breakpoint, function() require("dap").toggle_breakpoint() end, { noremap = true } },
    { "n",
      keys.dbg_continue,
      function()
        local ui_select = require("utils.ui").select
        ui_select(require("dap").continue)
      end,
      { noremap = true },
    },
    { "n", keys.dbg_step_over, function() require("dap").step_over() end, { noremap = true } },
    { "n", keys.dbg_step_into, function() require("dap").step_into() end, { noremap = true } },
    { "n", keys.dbg_eval, function() require("dapui").eval() end, { noremap = true }, } },
}

M.config = function()
  local dap = require "dap"
  vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "WarningMsg", linehl = "", numhl = "" })

  require "plugin.debug_langs.go"
  require "plugin.debug_langs.cpp"
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp

  local dapui = require "dapui"

  dapui.setup {
    icons = { expanded = "▾", collapsed = "▸" },
    mappings = {
      expand = "o",
      open = { "<CR>", "<2-LeftMouse>" },
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
  }

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end

  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end

  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  helper.setup_m(M)
end

return M
