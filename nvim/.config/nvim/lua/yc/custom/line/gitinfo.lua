local utils = require "utils.theme"

local M = {
  update_cnt = 0,
  theme = "StatusLineGitSigns",
  end_theme = "StatusLineNormal",
  cached_str = "",
}

---@return string
local get_info = function()
  local git_info = vim.b.gitsigns_status_dict
  if not git_info then
    return ""
  end

  local res = {}
  if git_info.added and git_info.added ~= 0 then
    table.insert(res, string.format("+%d", git_info.added))
  end

  if git_info.changed and git_info.changed ~= 0 then
    table.insert(res, string.format("~%d", git_info.changed))
  end

  if git_info.removed and git_info.removed ~= 0 then
    table.insert(res, string.format("-%d", git_info.removed))
  end

  if #res == 0 then
    return ""
  end

  return table.concat(res, " ")
end

local refresh = function()
  M.update_cnt = M.update_cnt + 1

  local info = get_info()
  M.cached_str = utils.add_theme(M.theme, info, M.end_theme)
end

M.start = function()
  vim.api.nvim_create_autocmd("User", {
    pattern = "GitSignsUpdate",
    callback = refresh,
  })

  vim.api.nvim_create_autocmd({ "BufEnter" }, { callback = refresh })
end

---@return string
M.metrics = function()
  return string.format("[GitInfo update cnt: %d]", M.update_cnt)
end

return M
