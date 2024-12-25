---@class yc.line.Component
local M = YcVim.extra.new_component "githead"

local style = "StatusLineGitHead"
local end_style = "StatusLineNormal"
local s = " %{get(b:,'gitsigns_head','')} "

M.content = YcVim.util.add_theme(style, s, end_style)

return M
