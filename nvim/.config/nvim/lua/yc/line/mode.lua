local api, fn = vim.api, vim.fn
local utils = require "yc.line.utils"

local M = {
  refresh_cnt = 0, ---@type integer
  cached_content = "", ---@type string
  end_theme = "StatusLine1", ---@type string
}

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

---@return number
local widthModef = function()
  local res = 0
  for _, mo in pairs(modemap) do
    local w = #mo
    if w > res then
      res = w
    end
  end
  return res
end

---@type number
local wid = widthModef()

M.refresh = function()
  M.refresh_cnt = M.refresh_cnt + 1
  local m = vim.fn.mode()
  if not stylecache[m] then
    local msg = modemap[m]
    local style = stylemap[m]
    stylecache[m] = utils.add_theme(style, msg, M.end_theme)
  end

  M.cached_content = stylecache[m]
end

local started = false

M.start = function()
  if started then
    return
  end

  if M.cached_content == "" then
    M.refresh()
  end

  api.nvim_create_autocmd("ModeChanged", {
    callback = function()
      M.refresh()
    end,
  })
end

---@return number
M.width = function()
  return wid
end

---@return string
M.to_string = function()
  return M.cached_content
end

---@return string
M.metrics = function()
  return string.format("[Mode refresh cnt: %d]", M.refresh_cnt)
end

return M
