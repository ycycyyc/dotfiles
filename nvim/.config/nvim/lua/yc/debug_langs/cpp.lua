local dap = require "dap"

-- (note):build gdb with python support
-- with-python=python binary path
-- gdb > 14.xxx
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

dap.configurations.cpp = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    args = {}, -- provide arguments if needed
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
  {
    name = "Select and attach to process",
    type = "gdb",
    request = "attach",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    pid = function()
      local name = vim.fn.input "Executable name (filter): "
      return require("dap.utils").pick_process { filter = name }
    end,
    cwd = "${workspaceFolder}",
  },
  {
    name = "Attach to gdbserver :1234",
    type = "gdb",
    request = "attach",
    target = "localhost:1234",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
  },
}

local function file_exists(filepath)
  local stat = vim.uv.fs_stat(filepath)
  return (stat and stat.type) and true or false
end

local local_config_file = vim.fn.getcwd() .. "/.dap_config.lua"

if file_exists(local_config_file) then
  vim.notify "local gdb dap config file exists"
  local local_configs = dofile(local_config_file)
  for _, local_config in ipairs(local_configs) do
    table.insert(dap.configurations.cpp, local_config)
  end
else
  vim.notify "local gdb dap config file doesn't exist"
end

