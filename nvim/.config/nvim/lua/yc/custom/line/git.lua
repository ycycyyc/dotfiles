local utils = require "utils.theme"

local M = {
  update_cnt = 0,
  theme = "",
  end_theme = "",
  cached_content = "",
  branch = "",
}

local current_git_dir = "" ---@type string
local started = false ---@type boolean

local sep = package.config:sub(1, 1)
local uv = vim.loop or vim.uv

local file_changed = sep ~= "\\" and uv.new_fs_event() or uv.new_fs_poll()

M.start = function()
  M.refresh()
end

M.update = function(branch)
  M.update_cnt = M.update_cnt + 1
  M.cached_content = utils.add_theme(M.theme, branch, M.end_theme)
end

M.refresh = function()
  local args = {}
  table.insert(args, "rev-parse")
  table.insert(args, "--abbrev-ref")
  table.insert(args, "HEAD")

  local job = require "plenary.job"
  job
    :new({
      command = "git",
      args = args,

      on_exit = function(j, exit_code)
        if exit_code ~= 0 then
          M.update ""
          return
        end
        local branch = table.concat(j:result(), "\n")

        if branch == M.branch then
          return
        end

        if M.branch ~= "" then
          vim.schedule(function()
            vim.defer_fn(function()
              vim.cmd "checktime"
              vim.notify "reload git file"
            end, 200)
          end)
        end

        M.branch = branch
        M.update(" " .. branch .. " ")
        M.start_watch_job()
      end,
    })
    :start()
end

M.watch_git_head_file = function(gitpath)
  if gitpath == ".git" then
    current_git_dir = vim.fn.expand "%:p:h" .. sep .. gitpath .. sep
  else
    current_git_dir = gitpath .. sep
  end
  M.do_update_branch_loop()
end

M.start_watch_job = function()
  if started == true then
    return
  end
  started = true

  local argsDir = {} ---@type string[]
  -- git rev-parse --git-dir
  table.insert(argsDir, "rev-parse")
  table.insert(argsDir, "--git-dir")

  local job = require "plenary.job"
  job
    :new({
      command = "git",
      args = argsDir,
      on_exit = function(j, exit_code)
        if exit_code ~= 0 then
          return
        end
        local res = table.concat(j:result(), "\n")
        vim.schedule(function()
          M.watch_git_head_file(res)
        end)
      end,
    })
    :start()
end

function M.do_update_branch_loop()
  file_changed:stop()
  local git_dir = current_git_dir
  if git_dir and #git_dir > 0 then
    local head_file = git_dir .. "HEAD"
    file_changed:start(
      head_file,
      sep ~= "\\" and {} or 1000,
      vim.schedule_wrap(function()
        M.refresh()
        -- reset file-watch
        M.do_update_branch_loop()
      end)
    )
  end
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
