local has_dap, dap = pcall(require, "dap")
if not has_dap then
  return
end

local stl_setup_command =
  { description = "Enable pretty-printing for lldb", text = "-enable-pretty-printing", ignoreFailures = true }

-- local dap = require('dap')
dap.adapters.lldb = {
  options = { initialize_timeout_sec = 180 },
  type = "executable",
  command = "/data/yc/download/llvm/llvm-project/build/bin/lldb-vscode", -- adjust as needed
  name = "lldb",
}

dap.adapters.codelldb = { type = "server", host = "127.0.0.1", port = 13000 }

dap.configurations.cpp = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    -- program = '/data/yc/cpp/test-debug/a.out',
    -- program = vim.fn.getcwd() .. '/a.out',
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},

    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --
    -- Otherwise you might get the following error:
    --
    --    Error on launch: Failed to attach to the target process
    --
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    runInTerminal = false,
  },
  {
    name = "debug test xmake main",
    type = "lldb",
    request = "launch",
    program = "./build/linux/x86_64/release/main",
    -- program = '/data/yc/cpp/test-debug/a.out',
    -- program = vim.fn.getcwd() .. '/a.out',
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
    MIMode = "lldb",
    miDebuggerPath = "/data/yc/download/llvm-project/build/bin/lldb-vscode",
    setupCommands = { stl_setup_command },
    runInTerminal = false,
  },
  {
    name = "debug mongo40",
    type = "lldb",
    request = "launch",
    program = "/data/mongo/yc/mongo40/mymongo/bin/mongod",
    -- program = '/data/yc/cpp/test-debug/a.out',
    --         -- program = vim.fn.getcwd() .. '/a.out',
    --                 cwd = '${workspaceFolder}',
    --                         stopOnEntry = false,
    args = { "-f", "/data/mongo/yc/mongo40/shard/conf/mongod1.conf" },
    runInTerminal = false,
    setupCommands = { stl_setup_command },
    -- postRunCommands = {'settings set target.process.follow-fork-mode child'}
    --
  },
  {
    name = "code codelldb",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    -- program = '${fileDirname}/${fileBasenameNoExtension}',
    cwd = "${workspaceFolder}",
    terminal = "integrated",
  },
}
