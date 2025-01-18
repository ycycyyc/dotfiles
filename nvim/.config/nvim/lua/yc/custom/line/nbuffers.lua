local style = "StatusLineNBuffers"
local end_style = "StatusLineNormal"

local M = YcLine.new_section "nBuffer"

local s = " %{get(g:,'ycvim_buf_number','')} Buffer(s) "
M.content = YcVim.util.add_theme(style, s, end_style)

return M
