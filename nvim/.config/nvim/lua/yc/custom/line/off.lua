---@type yc.line.Component
local M = YcVim.extra.new_component "off"

M.content = YcVim.util.add_theme("StatusLineOff", " %l of %L ", "StatusLineNormal")

return M
