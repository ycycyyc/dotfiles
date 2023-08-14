local api, fn = vim.api, vim.fn

local M = {
  refresh_buflist_count = 0, ---@type number
  refresh_mode_count = 0,
  max_cost = 0.0, ---@type number
  line = "", ---@type string
  mode = "",
}

local originFileAndNum = "%{expand('%:~:.')}%m%h %#StatusLine2# %l of %L "

local current_mode = {
  n = "%#StatusNormalMode# NORMAL %#StatusLine1#",
  v = "%#StatusVisMode# VISUAL %#StatusLine1#",
  V = "%#StatusVlMode# VI LINE %#StatusLine1#",
  i = "%#StatusInsertMode# INSERT %#StatusLine1#",
  c = "%#StatusCmdMode# COMMAND %#StatusLine1#",
  t = "%#StatusTermMode# TERMINAL %#StatusLine1#",
  s = "%#StatusSelMode# SELECT %#StatusLine1#",
  S = "%#StatusSelMode# SELECT %#StatusLine1#",
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

current_mode["CTRL-V"] = "%#StatusVisMode# VIRTUAL %#StatusLine1#"

---@return number
local widthModef = function()
  local res = 0
  for _, mo in pairs(current_mode) do
    local w = api.nvim_eval_statusline(mo, { use_tabline = true }).width ---@type number
    if w > res then
      res = w
    end
  end
  return res
end

---@type number
local widthMode = widthModef()

M.refresh_mode = function()
  M.refresh_mode_count = M.refresh_mode_count + 1
  local m = vim.fn.mode()
  if current_mode[m] ~= nil then
    M.mode = current_mode[m]
  else
    local msg = modemap[m]
    M.mode = "%#StatusNormalMode# " .. msg .. " %#StatusLine1#"
  end
end

function M.update_line()
  ---@type number
  local cur_buf_is_listed = 0

  local cur_bufnr = api.nvim_get_current_buf() ---@type number
  local abufnr_list = api.nvim_list_bufs() ---@type number[]
  local buflisted = fn.buflisted

  local bufnr_list = {} ---@type number[]
  for _, bufnr in ipairs(abufnr_list) do
    if buflisted(bufnr) == 1 then
      if cur_bufnr == bufnr then
        cur_buf_is_listed = 1
      end
      table.insert(bufnr_list, bufnr)
    end
  end

  if cur_buf_is_listed == 0 then
    return
  end

  local find_cur_buf ---@type nil|number
  local total_len = 0 ---@type number

  ---@type string[]
  local buf_items = {}
  ---@type string
  local nbuffers_str = string.format("%%#NumberBuffers# %d Buffers ", #bufnr_list)

  -- local widthRighFile = api.nvim_eval_statusline(fileAndNum, { use_tabline = true }).width ---@type number
  local widthBuf = api.nvim_eval_statusline(nbuffers_str, { use_tabline = true }).width ---@type number
  ---@type number
  local max_len = vim.o.columns - widthBuf - widthMode -- -widthRighFile

  ---@type number[]
  local buf_lens = {}

  local bufname_of = fn.bufname

  for _, bufnr in ipairs(bufnr_list) do
    local sel = "%#StatusLine3#"

    if bufnr == cur_bufnr then
      sel = "%#StatusLineCurFile#"
      find_cur_buf = #buf_items + 1
    end

    local bufname = bufname_of(bufnr)
    local filename = fn.fnamemodify(bufname, ":t") ---@type string
    if bufname == "" then
      filename = "[no name]"
    end

    if bufnr == cur_bufnr then
      filename = originFileAndNum
    end

    local item = string.format(" %%%dT%s %d %s %%#StatusLine1#", bufnr, sel, bufnr, filename)
    local l = api.nvim_eval_statusline(item, { use_tabline = true }).width

    table.insert(buf_items, item)
    table.insert(buf_lens, l)
    total_len = total_len + l

    if find_cur_buf ~= nil and total_len > max_len then
      break
    end
  end

  if find_cur_buf ~= nil and total_len > max_len then
    local items_len = #buf_items

    local l = find_cur_buf ---@type number
    local r = find_cur_buf ---@type number
    local sz = buf_lens[find_cur_buf]

    while l ~= 1 or r ~= items_len do
      if r + 1 <= items_len then
        if sz + buf_lens[r + 1] > max_len then
          break
        end
        r = r + 1
        sz = sz + buf_lens[r]
      end

      if l - 1 >= 1 then
        if sz + buf_lens[l - 1] > max_len then
          break
        end
        l = l - 1
        sz = sz + buf_lens[l]
      end
    end

    --  mode %=  bustlist %= numberbuffer
    M.line = "%=" .. table.concat(buf_items, "", l, r) .. "%=" .. nbuffers_str
  else
    --  mode %=  bustlist %= numberbuffer
    table.insert(buf_items, 1, "%=")
    table.insert(buf_items, "%=" .. nbuffers_str)
    M.line = table.concat(buf_items)
  end
end

M.refresh = function()
  local start = vim.fn.reltime()

  M.update_line()

  M.refresh_buflist_count = M.refresh_buflist_count + 1
  local cost = vim.fn.reltimestr(vim.fn.reltime(start))

  if tonumber(cost) > M.max_cost then
    M.max_cost = tonumber(cost)
  end
end

M.setup = function()
  vim.opt.laststatus = 3
  vim.opt.showmode = false

  -- create statueline theme
  vim.cmd [[
      hi! StatusLine1 ctermfg=145 ctermbg=237

      hi! StatusLineCurFile ctermfg=235 ctermbg=114 cterm=bold
      hi! StatusLine2 ctermfg=235 ctermbg=114 cterm=bold

      hi! StatusLine3 ctermfg=145 ctermbg=239
      hi! NumberBuffers ctermfg=235 ctermbg=39 cterm=bold
      hi! WinSeparator ctermbg=237

      hi! StatusNormalMode ctermfg=235 ctermbg=39 cterm=bold
      hi! StatusInsertMode ctermfg=235 ctermbg=204 cterm=bold
      hi! StatusTermMode ctermfg=235 ctermbg=180 cterm=bold
      hi! StatusVisMode ctermfg=235 ctermbg=173 cterm=bold
      hi! StatusVlMode ctermfg=235 ctermbg=173 cterm=bold
      hi! StatusSelMode ctermfg=235 ctermbg=200 cterm=bold
      hi! StatusCmdMode ctermfg=235 ctermbg=39 cterm=bold

      augroup nobuflisted
        autocmd!
        autocmd FileType qf set nobuflisted
        autocmd FileType fugitive set nobuflisted
      augroup END
  ]]

  api.nvim_create_autocmd({ "BufEnter", "BufDelete" }, {
    callback = function()
      M.refresh()
    end,
  })

  api.nvim_create_autocmd("ModeChanged", {
    callback = function()
      M.refresh_mode()
    end,
  })

  api.nvim_create_user_command("ShowStatuslineStat", function()
    vim.print(
      "[StatusLine] refresh buflist cnt:"
        .. M.refresh_buflist_count
        .. " max cost:"
        .. M.max_cost
        .. " refresh mode cnt:"
        .. M.refresh_mode_count
    )
  end, {})

  function _G.yc_statusline()
    if M.mode == "" then
      M.refresh_mode()
    end
    return M.mode .. M.line
  end

  vim.opt.statusline = "%!v:lua.yc_statusline()"
end

return M
