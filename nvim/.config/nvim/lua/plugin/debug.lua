local plugin = {}

plugin.config = function()
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

  YcVim.setup_plugin(plugin)
end

local keys = YcVim.keys

return {
  "rcarriga/nvim-dap-ui",
  -- stylua: ignore
  keys = {
    { keys.dbg_breakpoint, function() require("dap").toggle_breakpoint() end, },
    { keys.dbg_continue, function() require("dap").continue() end, },
    { keys.dbg_step_over, function() require("dap").step_over() end, },
    { keys.dbg_step_into, function() require("dap").step_into() end, },
    { keys.dbg_eval, function() require("dapui").eval() end, },
  },
  config = plugin.config,
  dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
}
