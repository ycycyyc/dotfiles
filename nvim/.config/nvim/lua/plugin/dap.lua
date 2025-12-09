local icons = {
  Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
  Breakpoint = " ",
  BreakpointCondition = " ",
  BreakpointRejected = { " ", "DiagnosticError" },
  LogPoint = ".>",
}

vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

for name, sign in pairs(icons) do
  sign = type(sign) == "table" and sign or { sign }
  vim.fn.sign_define(
    "Dap" .. name,
    { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
  )
end

local config = function()
  local dap = require "dap"

  require "yc.debug_langs.go"
  require "yc.debug_langs.cpp"
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp

  local dapui = require "dapui"

  dapui.setup {
    controls = {
      element = "repl",
      enabled = true,
      icons = {
        disconnect = " disconnect",
        pause = " pause",
        play = " play",
        run_last = " run last",
        step_back = " back",
        step_into = " in",
        step_out = " out",
        step_over = " over",
        terminate = " terminate",
      },
    },
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
    YcVim.util.toggle_mouse(true)
    dapui.open()
  end

  dap.listeners.before.event_terminated["dapui_config"] = function()
    YcVim.util.toggle_mouse(false)
    dapui.close()
  end

  dap.listeners.before.event_exited["dapui_config"] = function()
    YcVim.util.toggle_mouse(false)
    dapui.close()
  end
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
  config = config,
  dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
}
