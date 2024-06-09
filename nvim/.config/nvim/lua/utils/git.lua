local M = {}

---使用diffview来对比commit

---@param commit string | nil
M.commit_diff = function(commit)
  if not commit then
    vim.cmd "DiffviewOpen"
    return
  end

  local idx = vim.fn.stridx(commit, "^") ---@type number
  local cmd = "" ---@type string

  if idx >= 0 then
    vim.notify "it's first commit"
    cmd = "DiffviewOpen " .. commit
  else
    cmd = "DiffviewOpen " .. commit .. "^!"
  end

  vim.notify("Run cmd: " .. cmd)
  vim.cmd(cmd)
end

---@param file string
M.file_diff = function(file)
  local cmd = "DiffviewOpen -- " .. file
  vim.notify("Run cmd: " .. cmd)
  vim.cmd(cmd)
end

return M
