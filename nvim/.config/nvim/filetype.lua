vim.filetype.add {
  filename = {
    [".zshrc"] = "bash",
  },
  pattern = {
    [".*%.i"] = function(path, _)
      local ok = string.find(path, "third_party/wiredtiger/")
      if ok then
        return "c"
      end
    end,
  },
}
