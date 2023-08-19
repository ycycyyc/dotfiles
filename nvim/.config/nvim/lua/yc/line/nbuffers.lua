local utils = require "yc.line.utils"

local M = {
  update_cnt = 0,
  cached_content = "", ---@type string
  theme = "StatusLine", ---@type string
  end_theme = "StatusLine", ---@type string
}

M.start = function() end

---@param n number
M.update = function(n)
  M.update_cnt = M.update_cnt + 1
  local c ---@type string
  if n == 1 then
    c = " 1 Buffer "
  else
    c = string.format(" %d Buffers ", n)
  end

  M.cached_content = utils.add_theme(M.theme, c, M.end_theme)
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
  return string.format("[nBuffer update cnt: %d]", M.update_cnt)
end

return M
