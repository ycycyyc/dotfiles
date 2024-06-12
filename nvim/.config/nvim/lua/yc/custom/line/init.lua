local utils = require "utils.theme"
local helper = require "utils.helper"
local env = require("basic.env").env

local module_prefix = "yc.custom.line."

local componentNames = { "mode", "githead", "gitinfo", "alig", "bufferlist", "alig", "off", "nbuffers" }
local components = {}

---@return number
function _G.yc_statusline_avail_width()
  local w = 0
  for _, c in ipairs(components) do
    if c.width then
      w = w + c.width
    else
      w = w + utils.evaluates_width(c.cached_str)
    end
  end
  return vim.o.columns - 10 - w -- 10是padding的长度
end

---@return string
function _G.yc_statusline()
  local res = {}
  for _, c in ipairs(components) do
    table.insert(res, c.cached_str)
  end
  return table.concat(res)
end

local refreshCnt = 0
local refresh = function()
  refreshCnt = refreshCnt + 1
  for _, c in ipairs(components) do
    if c.refresh and type(c.refresh) == "function" then
      c.refresh()
    end
  end
  vim.opt.statusline = "%!v:lua.yc_statusline()"
end

local stats = function()
  local msg = { "[refreshCnt:" .. tostring(refreshCnt) .. "]" }
  for _, c in ipairs(components) do
    if c.metrics then
      table.insert(msg, c.metrics())
    end
  end
  vim.notify(vim.inspect(msg))
end

local M = {
  user_cmds = { { "ShowLineStats", stats, {} } },
}

M.setup = function()
  vim.opt.laststatus = 3
  vim.opt.showmode = false

  for _, name in ipairs(componentNames) do
    local component = require(module_prefix .. name)
    table.insert(components, component)
    if component.start then
      component.start()
    end
  end

  refresh()

  vim.api.nvim_create_autocmd("User", {
    pattern = "LineRefresh",
    callback = function()
      vim.schedule(function()
        refresh()
      end)
    end,
  })

  helper.setup_m(M)

  if env.coc then
    require(module_prefix .. "coc_winbar").start()
  end
end

return M
