local api, fn = vim.api, vim.fn
local buflisted = fn.buflisted ---@type fun(number:number):number
local bufname_of = fn.bufname
local utils = require "yc.line.utils"

local originFileAndNum = "%{expand('%:~:.')}%m%h"

local M = {
  refresh_cnt = 0, ---@type number
  max_cost = 0, ---@type number
  max_cost0 = "",
  max_cost1 = "",
  max_cost2 = "",
  max_titles = 0,

  cached_content = "", ---@type string

  sel_theme = "StatusLine",
  theme = "StatusLine",
  end_theme = "StatusLine",

  ---@type function
  max_width_cb = function()
    return vim.o.columns
  end,

  nbuffers_cb = function(nBuffers) end,
}

---@param bufnr number
---@param iscur boolean
---@return string
M.title = function(bufnr, iscur)
  local filename ---@type string
  local theme
  if iscur then
    filename = originFileAndNum
    theme = M.sel_theme
  else
    local bufname = bufname_of(bufnr)
    filename = fn.fnamemodify(bufname, ":t") ---@type string
    if bufname == "" then
      filename = "[no name]"
    end
    theme = M.theme
  end

  -- local item = string.format(" %%%dT%s %d %s %%#StatusLine1#", bufnr, sel, bufnr, filename)
  local item = utils.add_theme(theme, string.format("%d %s", bufnr, filename), M.end_theme)
  item = string.format(" %%%dT%s", bufnr, item)

  return item
end

local cost0 = ""
local cost1 = ""
local cost2 = ""

M.update = function()
  cost0 = ""
  cost1 = ""
  cost2 = ""
  local start = vim.fn.reltime()

  local cur_bufnr = api.nvim_get_current_buf() ---@type number
  local index_of_cur_buffer_in_bufflist ---@type number|nil
  local bufnr_list = {} ---@type number[]

  for bufnr = 1, vim.fn.bufnr "$" do
    if buflisted(bufnr) == 1 then
      table.insert(bufnr_list, bufnr)

      if cur_bufnr == bufnr then
        index_of_cur_buffer_in_bufflist = #bufnr_list
      end
    end
  end

  cost0 = vim.fn.reltimestr(vim.fn.reltime(start))
  start = vim.fn.reltime()

  local bufnr_list_len = #bufnr_list ---@type number
  M.nbuffers_cb(bufnr_list_len)

  if not index_of_cur_buffer_in_bufflist then
    return
  end

  local titles = {} ---@type string[]
  table.insert(titles, M.title(cur_bufnr, true))

  local total_sz = utils.evaluates_width(titles[1])

  local l = index_of_cur_buffer_in_bufflist ---@type number
  local r = index_of_cur_buffer_in_bufflist ---@type number
  local max_len = M.max_width_cb() ---@type number

  cost1 = vim.fn.reltimestr(vim.fn.reltime(start))
  start = vim.fn.reltime()

  ---@param index number
  ---@param after boolean
  ---@return boolean
  local next_ok = function(index, after)
    local t = M.title(bufnr_list[index], false)
    local sz = utils.evaluates_width(t)
    if total_sz + sz > max_len then
      return false
    end
    total_sz = total_sz + sz

    if after == true then
      table.insert(titles, t)
    else
      table.insert(titles, 1, t)
    end

    return true
  end

  while l ~= 1 or r ~= bufnr_list_len do
    if r + 1 <= bufnr_list_len then
      if next_ok(r + 1, true) == false then
        break
      end
      r = r + 1
    end

    if l - 1 >= 1 then
      if next_ok(l - 1, false) == false then
        break
      end
      l = l - 1
    end
  end

  if #titles > M.max_titles then
    M.max_titles = #titles
  end

  M.cached_content = table.concat(titles)
  cost2 = vim.fn.reltimestr(vim.fn.reltime(start))
end

M.refresh = function()
  M.refresh_cnt = M.refresh_cnt + 1
  local start = vim.fn.reltime()

  M.update()

  local cost = vim.fn.reltimestr(vim.fn.reltime(start))
  if tonumber(cost) > M.max_cost then
    M.max_cost = tonumber(cost)
    M.max_cost0 = cost0
    M.max_cost1 = cost1
    M.max_cost2 = cost2
  end
end

M.start = function()
  api.nvim_create_autocmd({ "BufEnter", "BufDelete" }, {
    callback = function()
      M.refresh()
    end,
  })
end

---@return number
M.width = function()
  return 0
end

---@return string
M.to_string = function()
  return M.cached_content
end

---@return string
M.metrics = function()
  return string.format(
    "[BufferListSec refresh cnt: %d max cost: %s, max items: %d cost0:%s, cost1:%s, cost2:%s]",
    M.refresh_cnt,
    tostring(M.max_cost),
    M.max_titles,
    M.max_cost0,
    M.max_cost1,
    M.max_cost2
  )
end

return M
