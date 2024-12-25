---@class yc.line.Component
---@field content string
---@field width number?
---@field cnt number
---@field metrics fun():string?
---@field refresh fun()?
---@field start fun()?
local Component = {}

---@return yc.line.Component
YcVim.extra.new_component = function(name)
  local o = {}
  o.name = name
  o.content = ""
  o.cnt = 0
  return o
end

---@type string
local module_prefix = "yc.custom.line."

---@type string[]
local component_names = { "mode", "githead", "gitinfo", "alig", "bufferlist", "alig", "off", "nbuffers" }

---@type yc.line.Component[]
local components = {}

---@return number
function YcVim.extra.yc_statusline_avail_width()
  local w = 0 ---@type number
  for _, c in ipairs(components) do
    local add ---@type number
    if c.width then
      add = c.width
    else
      add = YcVim.util.evaluates_width(c.content)
    end
    w = w + add
  end
  local padding = 10
  return vim.o.columns - padding - w -- 10是padding的长度
end

---@return string
function YcVim.extra.yc_statusline()
  local res = {} ---@type string[]
  for _, c in ipairs(components) do
    table.insert(res, c.content)
  end
  return table.concat(res)
end

for _, name in ipairs(component_names) do
  local component = require(module_prefix .. name)
  table.insert(components, component)
  if component.start then
    component.start()
  end
end

local refresh_all_cnt = 0 ---@type number
local refresh_all = function()
  refresh_all_cnt = refresh_all_cnt + 1
  for _, c in ipairs(components) do
    if c.refresh then
      c.refresh()
    end
  end
  vim.opt.statusline = "%!v:lua.YcVim.extra.yc_statusline()"
end

refresh_all()

vim.api.nvim_create_autocmd("User", {
  pattern = "LineRefresh",
  callback = function()
    vim.schedule(function()
      refresh_all()
    end)
  end,
})

local show_line_stats = function()
  local msg = { "[refresh_all_cnt:" .. tostring(refresh_all_cnt) .. "]" } ---@type string[]
  for _, c in ipairs(components) do
    if c.metrics then
      table.insert(msg, c.metrics())
    end
  end
  vim.notify(vim.inspect(msg))
end

vim.api.nvim_create_user_command("ShowLineStats", show_line_stats, {})
