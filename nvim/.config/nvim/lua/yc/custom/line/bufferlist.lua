local api, fn = vim.api, vim.fn
local buflisted = fn.buflisted ---@type fun(number:number):number
local bufname_of = fn.bufname
local utils = require "utils.theme"

local M = {
  refresh_cnt = 0, ---@type number
  costs = {}, ---@type number[]
  max_items = 0,

  cached_str = "", ---@type string

  sel_theme = "StatusLineCurFile",
  theme = "StatusLineBufListNormal",
  end_theme = "StatusLineNormal",

  nbuffers_cb = function(_) end,
}

---@param bufnr number
---@param cur_buf_format string|nil
---@return string
local colorfy_item = function(bufnr, cur_buf_format)
  local filename ---@type string
  local theme
  if cur_buf_format then
    filename = cur_buf_format
    theme = M.sel_theme
  else
    local bufname = bufname_of(bufnr)
    filename = fn.fnamemodify(bufname, ":t") ---@type string
    if bufname == "" then
      filename = "[no name]"
    end
    theme = M.theme
  end

  -- local item = string.format(" %%%dT%s %d %s %%#StatusLine1#", bufnr, sel, bufnr, filename) why ??
  local item = utils.add_theme(theme, string.format("%d %s", bufnr, filename), M.end_theme)
  item = string.format(" %%%dT%s", bufnr, item)

  return item
end

---@return number[]
---@return number|nil
local get_listedbufs = function()
  local cur_index ---@type number|nil
  local bufnr_list = {} ---@type number[]

  local cur_bufnr = api.nvim_get_current_buf() ---@type number
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
local cal_fileitems = function()
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
  require("yc.custom.line.nbuffers").update(bufnr_list_len) -- 如何让俩个模块不关联?

  local colored_file_items = { colorfy_item(bufnr_list[cur_index], cur_buf_format) }
  local total_sz = utils.evaluates_width(colored_file_items[1])
  local available_sz = _G.yc_statusline_avail_width()

  ---@param index number
  ---@param forward boolean
  ---@return boolean
  local try_add = function(index, forward)
    local item = colorfy_item(bufnr_list[index])
    local sz = utils.evaluates_width(item)
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

local update_cached_content = function()
  local colored_file_items = cal_fileitems()
  if not colored_file_items then
    return
  end

  if #colored_file_items > M.max_items then
    M.max_items = #colored_file_items
  end

  M.cached_str = table.concat(colored_file_items)
end

M.refresh = function()
  M.refresh_cnt = M.refresh_cnt + 1
  local start = vim.fn.reltime()

  update_cached_content()

  local cost = vim.fn.reltimestr(vim.fn.reltime(start))

  if #M.costs > 10 then
    table.remove(M.costs, 1)
  end
  table.insert(M.costs, tonumber(cost))
end

M.start = function()
  api.nvim_create_autocmd({ "BufEnter" }, {
    callback = function()
      M.refresh()
    end,
  })

  local hasRefreshJob = false
  api.nvim_create_autocmd({ "BufDelete" }, {
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

---@return number
M.width = 0

---@return string
M.metrics = function()
  local av = 0

  for _, c in ipairs(M.costs) do
    av = av + c
  end

  av = av / 10

  return string.format(
    "[BufferList refresh cnt: %d average cost: %s, max items: %d ]",
    M.refresh_cnt,
    tostring(av),
    M.max_items
  )
end

return M
