local M = YcLine.new_section "gitinfo"

---@return string
local get_msg = function()
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

M.start = function()
  vim.api.nvim_create_autocmd("User", {
    pattern = "GitSignsUpdate",
    callback = M.refresh,
  })

  M.refresh()
  vim.api.nvim_create_autocmd({ "BufEnter" }, { callback = M.refresh })
end

M.refresh = function()
  M.cnt = M.cnt + 1

  local msg = get_msg()
  local style = "StatusLineGitInfos"
  local end_style = "StatusLineNormal"

  M.content = YcVim.util.add_theme(style, msg, end_style)
end

---@return string
M.metrics = function()
  return string.format("[GitInfo update cnt: %d]", M.cnt)
end

return M
