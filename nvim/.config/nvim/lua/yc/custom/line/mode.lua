local api, fn = vim.api, vim.fn

-- stylua: ignore
local modemap = {
  ['n']      = 'NORMAL',
  ['no']     = 'O-PENDING',
  ['nov']    = 'O-PENDING',
  ['noV']    = 'O-PENDING',
  ['no\22'] = 'O-PENDING',
  ['niI']    = 'NORMAL',
  ['niR']    = 'NORMAL',
  ['niV']    = 'NORMAL',
  ['nt']     = 'NORMAL',
  ['ntT']    = 'NORMAL',
  ['v']      = 'VISUAL',
  ['vs']     = 'VISUAL',
  ['V']      = 'V-LINE',
  ['Vs']     = 'V-LINE',
  ['\22']   = 'V-BLOCK',
  ['\22s']  = 'V-BLOCK',
  ['s']      = 'SELECT',
  ['S']      = 'S-LINE',
  ['\19']   = 'S-BLOCK',
  ['i']      = 'INSERT',
  ['ic']     = 'INSERT',
  ['ix']     = 'INSERT',
  ['R']      = 'REPLACE',
  ['Rc']     = 'REPLACE',
  ['Rx']     = 'REPLACE',
  ['Rv']     = 'V-REPLACE',
  ['Rvc']    = 'V-REPLACE',
  ['Rvx']    = 'V-REPLACE',
  ['c']      = 'COMMAND',
  ['cv']     = 'EX',
  ['ce']     = 'EX',
  ['r']      = 'REPLACE',
  ['rm']     = 'MORE',
  ['r?']     = 'CONFIRM',
  ['!']      = 'SHELL',
  ['t']      = 'TERMINAL',
}

-- stylua: ignore
local stylemap = {
  ['n']      = 'StatusNormalMode',
  ['no']     = 'StatusNormalMode',
  ['nov']    = 'StatusNormalMode',
  ['noV']    = 'StatusNormalMode',
  ['no\22'] =  'StatusNormalMode',
  ['niI']    = 'StatusNormalMode',
  ['niR']    = 'StatusNormalMode',
  ['niV']    = 'StatusNormalMode',
  ['nt']     = 'StatusNormalMode',
  ['ntT']    = 'StatusNormalMode',
  ['v']      = 'StatusVisMode',
  ['vs']     = 'StatusVisMode',
  ['V']      = 'StatusVisMode',
  ['Vs']     = 'StatusVisMode',
  ['\22']   =  'StatusVisMode',
  ['\22s']  =  'StatusVisMode',
  ['s']      = 'StatusSelMode',
  ['S']      = 'StatusSelMode',
  ['\19']   =  'StatusSelMode',
  ['i']      = 'StatusInsertMode',
  ['ic']     = 'StatusInsertMode',
  ['ix']     = 'StatusInsertMode',
  ['R']      = 'StatusInsertMode',
  ['Rc']     = 'StatusInsertMode',
  ['Rx']     = 'StatusInsertMode',
  ['Rv']     = 'StatusInsertMode',
  ['Rvc']    = 'StatusInsertMode',
  ['Rvx']    = 'StatusInsertMode',
  ['c']      = 'StatusCmdMode',
  ['cv']     = 'StatusCmdMode',
  ['ce']     = 'StatusCmdMode',
  ['r']      = 'StatusInsertMode',
  ['rm']     = 'StatusNormalMode',
  ['r?']     = 'StatusTermMode',
  ['!']      = 'StatusTermMode',
  ['t']      = 'StatusTermMode',
}

---@type table<string, string>
local stylecache = {}

---@type string
local end_style = "StatusLineNormal"

local M = YcLine.new_section "mode"

function M.start()
  M.refresh()
  vim.api.nvim_create_autocmd("ModeChanged", {
    callback = function()
      M.refresh()
    end,
  })
end

function M.refresh()
  M.cnt = M.cnt + 1
  local m = vim.fn.mode()
  if not stylecache[m] then
    local msg = modemap[m]
    local style = stylemap[m]
    stylecache[m] = YcVim.util.add_theme(style, msg, end_style)
  end
  M.content = stylecache[m]
end

---@return string
function M.metrics()
  return string.format("[Mode refresh cnt: %d]", M.cnt)
end

return M
