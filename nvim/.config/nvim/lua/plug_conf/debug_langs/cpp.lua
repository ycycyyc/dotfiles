local has_dap, _ = pcall(require, "dap")
if not has_dap then
  return
end

local mode = require("basic.env").cpp_debug_mode

-- local stl_setup_command = {description = "Enable pretty-printing for lldb", text = "-enable-pretty-printing", ignoreFailures = true}

if mode == "vscode" then
  require "plug_conf.debug_langs.vscode_cpp"
elseif mode == "lldb" then
  require "plug_conf.debug_langs.lldb_cpp"
else
  print("unknow cpp_debug_mode" .. mode)
end
