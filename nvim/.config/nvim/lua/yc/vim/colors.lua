---@class YcVim.colors
local colors = {
  red = { n = 204, gui = "#ff5f87" },
  blue = { n = 39, gui = "#00afff" },
  black = { n = 235, gui = "#262626" },
  dark_yellow = { n = 173, gui = "#d7875f" },
  yellow = { n = 180, gui = "#d7af87" },
  comment_grey = { n = 59, gui = "#5f5f5f" },
  menu_grey = { n = 237, gui = "#3a3a3a" },
  menu_grey2 = { n = 233, gui = "#121212" },
  green = { n = 114, gui = "#87d787" },
  white = { n = 145, gui = "#afafaf" },
  cyan = { n = 38, gui = "#00afd7" },
  purple = { n = 170, gui = "#d75fd7" },
  cursor_grey1 = { n = 236, gui = "#303030" },
  cursor_grey2 = { n = 237, gui = "#3a3a3a" },
  cursor_grey4 = { n = 239, gui = "#4e4e4e" },
  cursor_grey5 = { n = 240, gui = "#585858" },
  virtual_grey = { n = 242, gui = "#6c6c6c" },
  cmdline = { n = 235, gui = "#262626" },
  current_line = { n = 11, gui = "#ffff00" },
  fuzzy_match = { n = 75, gui = "#46a8ff" },
}

---@param opt table
---@return table
local function convert(opt)
  local res = {}

  for field, val in pairs(opt) do
    if field == "myfg" then
      res.fg = val.gui
      res.ctermfg = val.n
    elseif field == "mybg" then
      res.bg = val.gui
      res.ctermbg = val.n
    else
      res[field] = val
    end
  end

  return res
end

colors.convert = convert

return colors
