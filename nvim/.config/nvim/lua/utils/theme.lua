local M = {}

local evaluates_width_func = vim.api.nvim_eval_statusline

---@param theme string
---@return string
M.theme = function(theme)
  return string.format("%%#%s#", theme)
end

---@param a string
---@param content string
---@param b string|nil
---@return string
M.add_theme = function(a, content, b)
  if b ~= nil then
    return string.format("%s %s %s", M.theme(a), content, M.theme(b))
  else
    return string.format("%s %s", M.theme(a), content)
  end
end

---@param c string
---@return number
M.evaluates_width = function(c)
  local res = evaluates_width_func(c, { use_tabline = true })
  return res.width
end

return M
