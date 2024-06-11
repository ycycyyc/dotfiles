local dap = require "dap"

local mode = require("basic.env").env.go_debug_mode
local uv = vim.loop or vim.uv

if mode == "dlv" then
  dap.adapters.go = function(callback, _)
    local stdout = uv.new_pipe(false)
    local handle
    local pid_or_err
    local port = 38697
    local opts = { stdio = { nil, stdout }, args = { "dap", "-l", "127.0.0.1:" .. port }, detached = true }
    handle, pid_or_err = uv.spawn("dlv", opts, function(code)
      stdout:close()
      handle:close()
      if code ~= 0 then
        print("dlv exited with code", code)
      end
    end)
    assert(handle, "Error running dlv: " .. tostring(pid_or_err))
    stdout:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require("dap.repl").append(chunk)
        end)
      end
    end)
    -- Wait for delve to start
    vim.defer_fn(function()
      callback { type = "server", host = "127.0.0.1", port = port }
    end, 100)
  end

  -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
  dap.configurations.go = {
    { type = "go", name = "Debug", request = "launch", program = "${file}" },
    {
      type = "go",
      name = "Debug test", -- configuration for debugging test files
      request = "launch",
      mode = "test",
      program = "${file}",
    }, -- works with go.mod packages and sub packages
    {
      type = "go",
      name = "Debug test (go.mod)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}",
    },
    { type = "go", name = "Debug .", request = "launch", program = "." },
    { type = "go", name = "Debug empty", request = "launch", program = "" },
  }
elseif mode == "vscode" then
  -- use need nodejs and vscode-go to debug else
  local js_file = os.getenv "HOME" .. "/local/vscode-go/dist/debugAdapter.js"

  dap.adapters.go = { type = "executable", command = "node", args = { js_file } }
  dap.configurations.go = {
    {
      type = "go",
      name = "Debug launch",
      request = "launch",
      showLog = true,
      program = "${file}",
      dlvToolPath = vim.fn.exepath "dlv", -- Adjust to where delve is installed
    },
  }
else
  print("unknow go_debug_mode" .. mode)
end
