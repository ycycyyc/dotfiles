local utils = require "utils.theme"

local M = {
  update_cnt = 0,
  theme = "StatusLineBufListNormal",
  end_theme = "StatusLineNormal",
  cached_str = "",
  head = "",
}

local sep = package.config:sub(1, 1)
local uv = vim.loop or vim.uv

local file_changed = sep ~= "\\" and uv.new_fs_event() or uv.new_fs_poll()

M.start = function()
  M.refresh()
end

local update_cached_str = function()
  M.update_cnt = M.update_cnt + 1
  M.cached_str = utils.add_theme(M.theme, M.head, M.end_theme)
end

M.refresh = function()
  local on_err = function()
    M.head = ""
    update_cached_str()
  end

  ---@param head string
  local on_ok = function(head)
    if head == M.head then
      return
    end

    M.head = head
    update_cached_str()

    M.launch_once()
  end

  YcVim.git.head_async(on_ok, on_err)
end

---@param gitpath string
---@return string
local git_head_file = function(gitpath)
  local git_dir
  if gitpath == ".git" then
    git_dir = vim.fn.expand "%:p:h" .. sep .. gitpath .. sep
  else
    git_dir = gitpath .. sep
  end

  return git_dir .. "HEAD"
end

---@param file string
---@param cb function
local function watch_file(file, cb)
  file_changed:stop()

  file_changed:start(
    file,
    sep ~= "\\" and {} or 1000,
    vim.schedule_wrap(function()
      cb()
      watch_file(file, cb)
    end)
  )
end

local already_run = false ---@type boolean
M.launch_once = function()
  if already_run == true then
    return
  end
  already_run = true

  local file_changed_cb = function()
    M.refresh()
    vim.schedule(function()
      vim.defer_fn(function()
        vim.cmd "checktime"
        vim.notify "reload git file"
      end, 200)
    end)
  end

  -- 先要拿到gitpath, 然后进行监听
  local on_ok = function(gitpath)
    vim.schedule(function()
      local head_file = git_head_file(gitpath)
      watch_file(head_file, file_changed_cb)
    end)
  end

  YcVim.git.path_async(on_ok)
end

---@return string
M.metrics = function()
  return string.format("[GitHead update cnt: %d]", M.update_cnt)
end

return M
