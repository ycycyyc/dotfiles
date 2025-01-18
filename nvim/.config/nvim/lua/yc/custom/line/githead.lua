local M = YcLine.new_section "githead"

local style = "StatusLineGitHead"
local end_style = "StatusLineNormal"
local s = " %{get(g:,'gitsigns_head','')} "

M.content = YcVim.util.add_theme(style, s, end_style)

return M
