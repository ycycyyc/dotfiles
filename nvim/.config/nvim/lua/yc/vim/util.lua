---@class YcVim.util
local util = {}

util.has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

---@param major number
---@param minor number?
---@param patch number?
---@return boolean
util.since_nvim = function(major, minor, patch)
  minor = minor or 0
  patch = patch or 0

  local v = vim.version()
  if v.major > major then
    return true
  end
  if v.major == major then
    if v.minor > minor then
      return true
    end
    if v.minor == minor then
      if v.patch >= patch then
        return true
      end
    end
  end

  return false
end

---@param key string
---@param mode string
util.feedkey = function(key, mode)
  -- 这里的true和false是什么意思?
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), mode, true)
end

util.buf_only = function()
  local api = vim.api
  local cur = api.nvim_get_current_buf()

  local list = api.nvim_list_bufs()

  for _, i in ipairs(list) do
    if vim.fn.buflisted(i) == 1 then
      if i ~= cur then
        api.nvim_buf_delete(i, { force = false })
      end
    end
  end
end

function util.i_move_to_end()
  util.feedkey("<esc>", "n")
  util.feedkey("A", "n")
end

---@return integer[]
function util.get_visual_selection()
  ---@type integer | integer[]
  local startp = vim.fn.getpos "v" -- len == 4
  startp = startp[2]

  ---@type integer | integer[]
  local endp = vim.fn.getpos "." -- len == 4
  endp = endp[2]

  return { startp, endp }
end

---@param match function
---@return integer[]
local get_winnums = function(match)
  local win_nums = {}
  local wins = vim.api.nvim_list_wins()
  for _, win_num in ipairs(wins) do
    local buf_num = vim.fn.winbufnr(win_num)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf_num })
    if match(ft) then
      table.insert(win_nums, win_num)
    end
  end
  return win_nums
end

---@param wanted string
---@return integer[]
function util.get_winnums_byft(wanted)
  return get_winnums(function(ft)
    return ft == wanted
  end)
end

---@param wanted string
---@return integer[]
function util.get_winnums_like_ft(wanted)
  return get_winnums(function(ft)
    return string.match(ft, wanted) ~= nil
  end)
end

---@param wanted string
---@return boolean
function util.try_jumpto_ft_win(wanted)
  local win_nums = util.get_winnums_byft(wanted)

  if #win_nums == 0 then
    return false
  end

  -- jump first window
  vim.api.nvim_set_current_win(win_nums[1])
  vim.cmd "redraw"
  return true
end

function util.try_jumpto_next_item()
  local succ = util.try_jumpto_ft_win "qf"
  if succ == true then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("j", true, false, true), "n", true)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, false, true), "n", true)
  end
end

function util.try_jumpto_prev_item()
  local succ = util.try_jumpto_ft_win "qf"
  if succ == true then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("k", true, false, true), "n", true)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, false, true), "n", true)
  end
end

function util.win_only()
  local cur_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_list_wins()
  if #wins <= 1 then
    return
  end
  for _, win in ipairs(wins) do
    if win ~= cur_win then
      vim.api.nvim_win_close(win, true)
    end
  end
end

---@param str string
---@return number
function util.calculateHash(str)
  local hash = 0
  local len = string.len(str)
  for i = 1, len do
    local byte = string.byte(str, i)
    hash = (hash * 31 + byte) % (2 ^ 32) -- 使用简单的哈希算法
  end
  return hash
end

---@param theme string
---@return string
util.theme = function(theme)
  return string.format("%%#%s#", theme)
end

---@param a string
---@param content string
---@param b string|nil
---@return string
util.add_theme = function(a, content, b)
  if b ~= nil then
    return string.format("%s %s %s", util.theme(a), content, util.theme(b))
  else
    return string.format("%s %s", util.theme(a), content)
  end
end

---@param c string
---@return number
util.evaluates_width = function(c)
  local evaluates_width_func = vim.api.nvim_eval_statusline
  local res = evaluates_width_func(c, { use_tabline = true })
  return res.width
end

local mouseEnable = false ---@type boolean

---@param enable boolean?
util.toggle_mouse = function(enable)
  local on = function()
    vim.opt.mouse = "nv"
    mouseEnable = true
    vim.notify "set mouse=nv"
  end

  local off = function()
    vim.opt.mouse = ""
    mouseEnable = false
    vim.notify "set mouse="
  end

  if enable == true then
    on()
  elseif enable == false then
    off()
  elseif mouseEnable == false then
    on()
  else
    off()
  end
end

return util
