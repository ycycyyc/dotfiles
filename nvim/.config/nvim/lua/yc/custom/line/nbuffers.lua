local style = "StatusLineNBuffers"
local end_style = "StatusLineNormal"

---@class yc.line.Component
local M = YcVim.extra.new_component "nBuffer"

local s = " %{get(g:,'ycvim_buf_number','')} Buffer "
M.content = YcVim.util.add_theme(style, s, end_style)

return M
