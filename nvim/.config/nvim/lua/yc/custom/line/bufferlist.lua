local api, fn = vim.api, vim.fn
local buflisted = fn.buflisted ---@type fun(number:number):number
local bufname_of = fn.bufname
local util = YcVim.util

---@type yc.line.Component
local M = YcVim.extra.new_component "bufferlist"

local costs = {} ---@type number[]
local max_items = 0
local sel_sytle = "StatusLineCurFile"
local m_style = "StatusLineBufListNormal"
local end_style = "StatusLineNormal"

---@param bufnr number
---@param cur_buf_format string|nil
---@return string
local colorfy_item = function(bufnr, cur_buf_format)
  local filename ---@type string
  local style
  if cur_buf_format then
    filename = cur_buf_format
    style = sel_sytle
  else
    local bufname = bufname_of(bufnr)
    filename = fn.fnamemodify(bufname, ":t") ---@type string
    if bufname == "" then
      filename = "[no name]"
    end
    style = m_style
  end

  -- local item = string.format(" %%%dT%s %d %s %%#StatusLine1#", bufnr, sel, bufnr, filename) why ??
  local item = util.add_theme(style, string.format("%d %s", bufnr, filename), end_style)
  item = string.format(" %%%dT%s", bufnr, item)

  return item
end

---@return number[]
---@return number|nil
local get_listedbufs = function()
  local cur_index ---@type number|nil
  local bufnr_list = {} ---@type number[]

  local cur_bufnr = vim.api.nvim_get_current_buf() ---@type number
  for bufnr = 1, vim.fn.bufnr "$" do
    if buflisted(bufnr) == 1 then
      table.insert(bufnr_list, bufnr)

      if cur_bufnr == bufnr then
        cur_index = #bufnr_list
      end
    end
  end

  return bufnr_list, cur_index
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
local get_color_items = function()
  local bufnr_list, cur_index = get_listedbufs()
  local cur_buf_format = "%{expand('%:~:.')}%m%h"

  if not cur_index then
    local n = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })

    if ft == "terminal" then
      cur_index = list_insert(bufnr_list, n)
      cur_buf_format = "Terminal"
    else
      return nil
    end
  end

  local bufnr_list_len = #bufnr_list ---@type number
  vim.g.ycvim_buf_number = bufnr_list_len

  local colored_file_items = { colorfy_item(bufnr_list[cur_index], cur_buf_format) }
  local total_sz = util.evaluates_width(colored_file_items[1])
  local available_sz = YcVim.extra.yc_statusline_avail_width()

  ---@param index number
  ---@param forward boolean
  ---@return boolean
  local try_add = function(index, forward)
    local item = colorfy_item(bufnr_list[index])
    local sz = util.evaluates_width(item)
    if total_sz + sz > available_sz then
      return false
    end
    total_sz = total_sz + sz

    if forward == true then
      table.insert(colored_file_items, item)
    else
      table.insert(colored_file_items, 1, item)
    end
    return true
  end

  local left = cur_index - 1
  local right = cur_index + 1

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

  return colored_file_items
end

local update_content = function()
  local colored_file_items = get_color_items()
  if not colored_file_items then
    return
  end

  if #colored_file_items > max_items then
    max_items = #colored_file_items
  end

  M.content = table.concat(colored_file_items)
end

---@return number
M.width = 0

M.start = function()
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    callback = function()
      M.refresh()
    end,
  })

  local hasRefreshJob = false
  vim.api.nvim_create_autocmd({ "BufDelete" }, {
    callback = function()
      if hasRefreshJob then
        return
      end

      vim.defer_fn(function()
        M.refresh()
        hasRefreshJob = false
      end, 50)

      hasRefreshJob = true
    end,
  })
end

M.refresh = function()
  M.cnt = M.cnt + 1
  local start = vim.fn.reltime()

  update_content()

  local cost = vim.fn.reltimestr(vim.fn.reltime(start))

  if #costs > 10 then
    table.remove(costs, 1)
  end
  table.insert(costs, tonumber(cost))
end

M.metrics = function()
  local av = 0

  for _, c in ipairs(costs) do
    av = av + c
  end

  av = av / 10

  return string.format("[BufferList refresh cnt: %d average cost: %s, max items: %d ]", M.cnt, tostring(av), max_items)
end

return M
