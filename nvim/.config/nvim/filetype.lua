vim.filetype.add {
  pattern = {
    [".*%.i"] = function(path, bufnr)
      local ok = string.find(path, "third_party/wiredtiger/")
      if ok then
        return "c"
      end
    end,
  },
}
