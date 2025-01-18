---@type YcLine.setion
local M = YcLine.new_section "off"

M.content = YcVim.util.add_theme("StatusLineOff", " %l of %L ", "StatusLineNormal")

return M
