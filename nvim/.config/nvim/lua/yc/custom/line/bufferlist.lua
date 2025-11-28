local vimapi, vimfn = vim.api, vim.fn
local buflisted = vimfn.buflisted ---@type fun(number:number):number
local bufname_of = vimfn.bufname
local util = YcVim.util

local M = YcLine.new_section "bufferlist"

---@param text string
---@param width integer
---@param left? boolean
function truncate(text, width, left)
  local tw = vimapi.nvim_strwidth(text)
  if tw > width then
    return left and "…" .. vimfn.strcharpart(text, tw - width + 1, width - 1)
      or vimfn.strcharpart(text, 0, width - 1) .. "…"
  end
  return text
end

local costs = {} ---@type integer[]
local max_buf_list_len = 0
local select_sytle = "StatusLineCurFile"
local normal_style = "StatusLineBufListNormal"
local end_style = "StatusLineNormal"

---@param bufnr integer
---@param cur_buf_display_content string|nil
---@param use_select_style boolean?
---@return string
local calc_colorfy_buf = function(bufnr, cur_buf_display_content, use_select_style)
  local filename ---@type string
  local style

  if cur_buf_display_content then
    filename = cur_buf_display_content
    style = select_sytle
  else
    local tmp_filename = truncate(bufname_of(bufnr), 40, true)
    filename = vimfn.fnamemodify(tmp_filename, ":t") ---@type string
    if tmp_filename == "" then
      filename = "[no name]"
    end

    style = normal_style
  end

  if use_select_style then
    style = select_sytle
  end

  -- local item = string.format(" %%%dT%s %d %s %%#StatusLine1#", bufnr, sel, bufnr, filename) why ??
  local colored_buf = util.add_theme(style, string.format("%d %s", bufnr, filename), end_style)
  colored_buf = string.format(" %%%dT%s", bufnr, colored_buf)

  return colored_buf
end

---@return integer[]
---@return integer|nil
local get_listedbufs = function()
  local cur_buf_index ---@type integer|nil
  local bufnr_list = {} ---@type integer[]

  local cur_bufnr = vimapi.nvim_get_current_buf()
  for bufnr = 1, vimfn.bufnr "$" do
    if buflisted(bufnr) == 1 then
      table.insert(bufnr_list, bufnr)

      if cur_bufnr == bufnr then
        cur_buf_index = #bufnr_list
      end
    end
  end

  return bufnr_list, cur_buf_index
end

local list_insert = function(list, new)
  for i, l in ipairs(list) do
    if l > new then
      table.insert(list, i, new)
      return i
    end
  end

  table.insert(list, new)
  return #list
end

---@return string[]|nil
local get_all_colored_buf_list = function()
  local bufnr_list, cur_buf_index = get_listedbufs()
  local cur_buf_content = "%{expand('%:~:.')}%m%h"

  if not cur_buf_index then
    local n = vimapi.nvim_get_current_buf()
    local ft = vimapi.nvim_get_option_value("filetype", { buf = 0 })

    if ft == "terminal" or ft == "snacks_terminal" then
      cur_buf_index = list_insert(bufnr_list, n)
      cur_buf_content = "Terminal"
    else
      return nil
    end
  end

  local bufnr_list_len = #bufnr_list ---@type number
  vim.g.ycvim_buf_number = bufnr_list_len

  local colored_buf_list
  if util.evaluates_width(cur_buf_content) > 50 then
    colored_buf_list = { calc_colorfy_buf(bufnr_list[cur_buf_index], nil, true) }
  else
    colored_buf_list = { calc_colorfy_buf(bufnr_list[cur_buf_index], cur_buf_content) }
  end

  local total_sz = util.evaluates_width(colored_buf_list[1])
  local available_sz = YcLine.avail_width()

  ---@param index number
  ---@param forward boolean
  ---@return boolean
  local try_add = function(index, forward)
    local colored_buf = calc_colorfy_buf(bufnr_list[index])
    local sz = util.evaluates_width(colored_buf)
    if total_sz + sz > available_sz then
      return false
    end
    total_sz = total_sz + sz

    if forward == true then
      table.insert(colored_buf_list, colored_buf)
    else
      table.insert(colored_buf_list, 1, colored_buf)
    end
    return true
  end

  local left = cur_buf_index - 1
  local right = cur_buf_index + 1

  while left >= 1 or right <= bufnr_list_len do
    if right <= bufnr_list_len then
      if not try_add(right, true) then
        break
      end
      right = right + 1
    end

    if left >= 1 then
      if not try_add(left, false) then
        break
      end
      left = left - 1
    end
  end

  return colored_buf_list
end

local update_content = function()
  local colored_buf_list = get_all_colored_buf_list()
  if not colored_buf_list then
    return
  end

  if #colored_buf_list > max_buf_list_len then
    max_buf_list_len = #colored_buf_list
  end

  M.content = table.concat(colored_buf_list)
end

M.width = 0

M.start = function()
  vimapi.nvim_create_autocmd({ "BufEnter", "BufAdd" }, {
    callback = function()
      if M.refresh then
        M.refresh()
      end
    end,
  })

  local hasRefreshJob = false
  vimapi.nvim_create_autocmd({ "BufDelete" }, {
    callback = function()
      if hasRefreshJob then
        return
      end

      vim.defer_fn(function()
        if M.refresh then
          M.refresh()
          hasRefreshJob = false
        end
      end, 50)

      hasRefreshJob = true
    end,
  })
end

M.refresh = function()
  M.cnt = M.cnt + 1
  local start = vimfn.reltime()

  update_content()

  local cost = vimfn.reltimestr(vimfn.reltime(start))

  if #costs > 10 then
    table.remove(costs, 1)
  end
  table.insert(costs, tonumber(cost))
end

M.metrics = function()
  local av = 0 ---@type integer

  for _, c in ipairs(costs) do
    av = av + c
  end

  av = av / 10

  return string.format(
    "[BufferList refresh cnt: %d average cost: %s, max items: %d ]",
    M.cnt,
    tostring(av),
    max_buf_list_len
  )
end

return M
