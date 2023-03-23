local M = {}

M.config = function()
  local has_dap, dap = pcall(require, "dap")
  if not has_dap then
    return
  end

  local keys = require "basic.keys"
  local nnoremap = require("utils.helper").nnoremap()

  nnoremap(keys.dbg_breakpoint, require("dap").toggle_breakpoint)
  nnoremap(keys.dbg_continue, require("dap").continue)
  nnoremap(keys.dbg_step_over, require("dap").step_over)
  nnoremap(keys.dbg_step_into, require("dap").step_into)
  nnoremap(keys.dbg_eval, require("dapui").eval)

  vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "", linehl = "", numhl = "" })

  require "plug_conf.debug_langs.go"
  require "plug_conf.debug_langs.cpp"

  -- If you want to use this for rust and c, add something like this:
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp

  local dapui = require "dapui"

  require("dapui").setup {
    icons = { expanded = "▾", collapsed = "▸" },
    mappings = {
      -- Use a table to apply multiple mappings
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    -- Expand lines larger than the window
    -- Requires >= 0.7
    expand_lines = vim.fn.has "nvim-0.7",
    -- Layouts define sections of the screen to place windows.
    -- The position can be "left", "right", "top" or "bottom".
    -- The size specifies the height/width depending on position. It can be an Int
    -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
    -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
    -- Elements are the elements shown in the layout (in order).
    -- Layouts are opened in order so that earlier layouts take priority in window sizing.
    layouts = {
      {
        elements = {
          -- Elements can be strings or table with id and size keys.
          { id = "scopes", size = 0.25 },
          "breakpoints",
          "stacks",
          "watches",
        },
        size = 40, -- 40 columns
        position = "left",
      },
      {
        elements = { "repl" },
        size = 0.25, -- 25% of total lines
        position = "bottom",
      },
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil, -- Floats will be treated as percentage of your screen.
      border = "single", -- Border style. Can be "single", "double" or "rounded"
      mappings = { close = { "q", "<Esc>" } },
    },
    windows = { indent = 1 },
    render = {
      max_type_length = nil, -- Can be integer or nil.
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

  require("nvim-dap-virtual-text").setup {
    enabled = true,

    -- DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, DapVirtualTextForceRefresh
    enabled_commands = false,

    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
    highlight_changed_variables = true,
    highlight_new_as_changed = true,

    -- prefix virtual text with comment string
    commented = false,

    show_stop_reason = true,

    -- experimental features:
    virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
    all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
  }
end

return M
