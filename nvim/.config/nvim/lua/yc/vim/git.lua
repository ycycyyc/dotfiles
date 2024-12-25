local git = {}

---@param commit string | nil
git.commit_diff = function(commit)
  vim.notify "not support commit diff"
end

---@param file string
git.file_diff = function(file)
  vim.notify "not support file diff"
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

---@param args string[]
---@param on_ok function
---@param on_err function | nil
local git_sync = function(args, on_ok, on_err)
  local job = require "plenary.job"
  local jn = job:new {
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
  }
  jn:sync()
end

---@param on_ok function
---@param on_err function | nil
git.head_async = function(on_ok, on_err)
  local args = {}
  table.insert(args, "rev-parse")
  table.insert(args, "--abbrev-ref")
  table.insert(args, "HEAD")

  git_async(args, function(res)
    local head = table.concat(res, "\n")
    on_ok(head)
  end, on_err)
end

---@return string
git.head = function()
  local args = {}
  table.insert(args, "rev-parse")
  table.insert(args, "--abbrev-ref")
  table.insert(args, "HEAD")

  local res = ""
  git_sync(args, function(r)
    if #r > 0 then
      res = r[1]
    end
  end)
  return res
end

---@param on_ok function
---@param on_err function|nil
git.path_async = function(on_ok, on_err)
  local args = {}
  table.insert(args, "rev-parse")
  table.insert(args, "--git-dir")

  git_async(args, function(res)
    local gitpath = table.concat(res, "\n")
    on_ok(gitpath)
  end, on_err)
end

git.add_file = function()
  local Job = require "plenary.job"
  local args = {}
  local file = vim.fn.expand "%:p"
  table.insert(args, "add")
  table.insert(args, "--")
  table.insert(args, file)

  git_async(args, function()
    vim.notify("add file" .. file .. " success")
    vim.schedule(function()
      vim.cmd "silent write" -- 写文件触发neogit状态的更新
    end)
  end, function()
    vim.schedule(function()
      vim.notify("add file" .. file .. " failed")
    end)
  end)
end

return git
