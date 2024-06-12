local utils = require "utils.theme"

local M = {
  update_cnt = 0,
  cached_str = "No Buffer", ---@type string
  theme = "NumberBuffers",
  end_theme = "StatusLineNormal",
}

---@param n number
M.update = function(n)
  M.update_cnt = M.update_cnt + 1
  local c ---@type string
  if n == 1 then
    c = " 1 Buffer "
  else
    c = string.format(" %d Buffers ", n)
  end

  M.cached_str = utils.add_theme(M.theme, c, M.end_theme)
end

---@return string
M.metrics = function()
  return string.format("[nBuffer update cnt: %d]", M.update_cnt)
end

return M
