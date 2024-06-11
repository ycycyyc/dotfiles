local dap = require "dap"
local mode = require("basic.env").env.cpp_debug_mode

-- local stl_setup_command = {description = "Enable pretty-printing for lldb", text = "-enable-pretty-printing", ignoreFailures = true}

if mode == "vscode" then
  require "plugin.debug_langs.vscode_cpp"
elseif mode == "lldb" then
  require "plugin.debug_langs.lldb_cpp"
else
  print("unknow cpp_debug_mode" .. mode)
end
