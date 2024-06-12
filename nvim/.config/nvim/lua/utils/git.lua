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

---@param args string[]
---@param on_ok function
---@param on_err function | nil
local git_async = function(args, on_ok, on_err)
  local job = require "plenary.job"
  job
    :new({
      command = "git",
      args = args,
      on_exit = function(j, exit_code)
        if exit_code ~= 0 then
          on_err = on_err or function() end
          on_err()
          return
        end
        on_ok(j:result())
      end,
    })
    :start()
end

---@param on_ok function
---@param on_err function | nil
M.head_async = function(on_ok, on_err)
  local args = {}
  table.insert(args, "rev-parse")
  table.insert(args, "--abbrev-ref")
  table.insert(args, "HEAD")

  git_async(args, function(res)
    local head = table.concat(res, "\n")
    on_ok(head)
  end, on_err)
end

---@param on_ok function
---@param on_err function|nil
M.gitpath_async = function(on_ok, on_err)
  local args = {}
  table.insert(args, "rev-parse")
  table.insert(args, "--git-dir")

  git_async(args, function(res)
    local gitpath = table.concat(res, "\n")
    on_ok(gitpath)
  end, on_err)
end

return M
