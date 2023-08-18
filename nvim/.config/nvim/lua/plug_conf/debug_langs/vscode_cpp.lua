local dap = require "dap"

dap.adapters.cppdbg = {
  options = { initialize_timeout_sec = 180 },
  id = "cppdbg",
  type = "executable",
  command = "/data/yc/local/vscode_cpp_debug/extension/debugAdapters/bin/OpenDebugAD7",
}

dap.configurations.cpp = {
  {
    name = "Launch wt test file",
    type = "cppdbg",
    request = "launch",
    program = "/data/yc/cpp/wt/wt_40/wiredtiger/examples/c/ex_access",
    cwd = "${workspaceFolder}",
    stopOnEntry = true,
    setupCommands = {
      { text = "-enable-pretty-printing", description = "enable pretty printing", ignoreFailures = true },
    },
  },
  {
    name = "Launch file",
    type = "cppdbg",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = true,
    setupCommands = {
      { text = "-enable-pretty-printing", description = "enable pretty printing", ignoreFailures = true },
      -- {text = "source ${workspaceFolder}/.gdbinit"}
    },
  },
  {
    name = "Attach to gdbserver :1234",
    type = "cppdbg",
    request = "launch",
    MIMode = "gdb",
    miDebuggerServerAddress = "localhost:1234",
    miDebuggerPath = "/usr/local/bin/gdb",
    cwd = "${workspaceFolder}",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
  },
  {
    name = "Attach to mongod40, use gdb vscode",
    type = "cppdbg",
    request = "attach",
    MIMode = "gdb",
    processId = function()
      local handle = io.popen "pgrep mongod"
      local process_id = handle:read()
      handle:close()
      local id = tonumber(process_id)
      return id
    end,
    miDebuggerPath = "/usr/local/bin/gdb",
    -- cwd = '${workspaceFolder}',
    -- program = function()
    --     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    -- end,
    program = "${workspaceFolder}/mongod",
    cwd = "${workspaceFolder}",
    setupCommands = {
      { text = "source ${workspaceFolder}/.gdbinit" },
      { text = "-enable-pretty-printing", description = "enable pretty printing", ignoreFailures = false },
    },
  },
  {
    name = "Launch mongod40,  use gdb vscode",
    type = "cppdbg",
    request = "launch",
    program = "/data/mongo/yc/mongo40/mongodb4_0_proj/mongod",
    args = { "-f", "/data/mongo/yc/mongo40/shard/conf/mongod1.conf" },
    cwd = "${workspaceFolder}",
    -- stopOnEntry = true,
    serverLaunchTimeout = 100000,
    setupCommands = {
      { text = "-enable-pretty-printing", description = "enable pretty printing", ignoreFailures = true },
      { text = "source ${workspaceFolder}/.gdbinit" },
    },
  },
  {
    name = "Launch mongod40 single node,  use gdb vscode",
    type = "cppdbg",
    request = "launch",
    program = "/data/mongo/yc/mongo40/mongodb4_0_proj/mongod",
    args = { "-f", "/data/mongo/yc/mongo40/mymongo/conf/mongod.conf" },
    cwd = "${workspaceFolder}",
    -- stopOnEntry = true,
    serverLaunchTimeout = 100000,
    setupCommands = {
      { text = "-enable-pretty-printing", description = "enable pretty printing", ignoreFailures = true },
      { text = "source ${workspaceFolder}/.gdbinit" },
    },
  },

  {
    name = "Launch mongod40 single node,  use gdb vscode",
    type = "cppdbg",
    request = "launch",
    program = "./build/debug/mongo/mongod",
    args = { "-f", "/data/mongo/yc/mongo40/shard/shard_cluster/mongod/conf/mongo.conf" },
    cwd = "${workspaceFolder}",
    -- stopOnEntry = true,
    serverLaunchTimeout = 100000,
    setupCommands = {
      { text = "-enable-pretty-printing", description = "enable pretty printing", ignoreFailures = true },
      { text = "source ${workspaceFolder}/.gdbinit" },
    },
  },
}
