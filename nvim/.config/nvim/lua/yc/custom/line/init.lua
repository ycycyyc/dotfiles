---@class YcLine.setion
---@field content string
---@field width number?
---@field cnt number
---@field metrics fun():string?
---@field refresh fun()?
---@field start fun()?

YcLine = {}

---@param name string
---@return YcLine.setion
YcLine.new_section = function(name)
  local section = {}
  section.name = name
  section.content = ""
  section.cnt = 0
  return section
end

---@type YcLine.setion[]
local sections = {}

---@return string
YcLine.statusline = function()
  local res = {} ---@type string[]
  for _, sec in ipairs(sections) do
    table.insert(res, sec.content)
  end
  return table.concat(res)
end

---@return number
YcLine.avail_width = function()
  local w = 0 ---@type number
  for _, section in ipairs(sections) do
    local add ---@type number
    if section.width then
      add = section.width
    else
      add = YcVim.util.evaluates_width(section.content)
    end
    w = w + add
  end
  local padding = 10
  return vim.o.columns - padding - w -- 10是padding的长度
end

---@type string[]
local section_names = { "mode", "githead", "gitinfo", "alig", "bufferlist", "alig", "off", "nbuffers" }
for _, name in ipairs(section_names) do
  local module_prefix = "yc.custom.line."
  local section = require(module_prefix .. name) ---@type YcLine.setion
  table.insert(sections, section)
  if section.start then
    section.start()
  end
end

local render_cnt = 0 ---@type number
local render = function()
  render_cnt = render_cnt + 1
  for _, sec in ipairs(sections) do
    if sec.refresh then
      sec.refresh()
    end
  end
  vim.opt.statusline = "%!v:lua.YcLine.statusline()"
end

render()

vim.api.nvim_create_autocmd("User", {
  pattern = "LineRefresh",
  callback = function()
    vim.schedule(function()
      render()
    end)
  end,
})

local stats = function()
  local msg = { "[refresh_all_cnt:" .. tostring(render_cnt) .. "]" } ---@type string[]
  for _, section in ipairs(sections) do
    if section.metrics then
      table.insert(msg, section.metrics())
    end
  end
  vim.notify(vim.inspect(msg))
end

vim.api.nvim_create_user_command("ShowLineStats", stats, {})
