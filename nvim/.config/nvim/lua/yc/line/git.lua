local utils = require "yc.line.utils"

local M = {
  update_cnt = 0,
  theme = "",
  end_theme = "",
  cached_content = "",
}

local args = {}
table.insert(args, "rev-parse")
table.insert(args, "--abbrev-ref")
table.insert(args, "HEAD")

M.start = function()
  local timer = vim.loop.new_timer()
  timer:start(1000, 1000, function()
    M.refresh()
  end)
  M.refresh()
end

M.update = function(branch)
  M.update_cnt = M.update_cnt + 1
  M.cached_content = utils.add_theme(M.theme, branch, M.end_theme)
end

M.refresh = function()
  local job = require "plenary.job"
  job
    :new({
      command = "git",
      args = args,

      on_exit = function(j, exit_code)
        if exit_code ~= 0 then
          M.update "[git error]"
          return
        end
        local res = table.concat(j:result(), "\n")
        M.update(" " .. res .. " ")
      end,
    })
    :start()
end

---@return number
M.width = function()
  return utils.evaluates_width(M.cached_content)
end

---@return string
M.to_string = function()
  return M.cached_content
end

---@return string
M.metrics = function()
  return string.format("[GitBranch update cnt: %d]", M.update_cnt)
end

return M
