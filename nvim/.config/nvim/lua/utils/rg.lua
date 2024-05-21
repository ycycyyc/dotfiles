local M = {}

---@class Yc.Finder
---@field rg string[]
---@field islive boolean|nil
---@field query string
---@field items string[]
---@field filepath string|nil
local Finder = {}

---@param args table
---@return Yc.Finder
function Finder:new(args)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.query = args["args"]
  self.items = args["fargs"]
  -- stylua: ignore
  self.rg = { "rg", "-H", "--hidden", "--column", "--line-number", "--no-heading", "--glob=!.git/", "--color=always", "--smart-case" }
  self.filepath = nil
  return o
end

local types_mapping = {
  ["-t cpp"] = "-t cpp -t c",
  ["-t c"] = "-t cpp -t c",
  ["-t go"] = "-t go",
  ["-t lua"] = "-t lua",
  ["-t rust"] = "-t rust",
}

---@param str string
---@return boolean
---@return integer
function Finder:have(str)
  for index, item in ipairs(self.items) do
    if item == str then
      return true, index
    end
  end
  return false, 0
end

function Finder:parse()
  ---@type table<string, fun(index: integer)>
  local handlers = {
    ["-t"] = function(index)
      -- 最后一个提前退出
      if index == #self.items then
        return
      end
      -- TODO:后面再适配-t go 中间出现很多个空格的情况
      for k, v in pairs(types_mapping) do
        local start, _ = string.find(self.query, k)
        if start ~= nil then
          table.insert(self.rg, v)
          self.query = string.gsub(self.query, k, "")
          self.query = string.gsub(self.query, "%s+$", "") --删除最后面的空字符
        end
      end
    end,
    ["--"] = function(index)
      -- 最后一个提前退出
      if index == #self.items then
        return
      end
      self.filepath = self.items[index + 1]
      self.query = string.gsub(self.query, "%-%-", "") -- TODO 如何避免删错了
      self.query = string.gsub(self.query, self.items[index + 1], "")
      self.query = string.gsub(self.query, "%s+$", "") --删除最后面的空字符
    end,
    ["-i"] = function(_)
      self.query = string.gsub(self.query, "%-i", "") -- TODO 如何避免删错了
      self.query = string.gsub(self.query, "%s+$", "") --删除最后面的空字符
      self.islive = true
    end,
  }

  for key, handler in pairs(handlers) do
    local has, index = self:have(key)
    if has then
      handler(index)
    end
  end
end

---@param live_grep function
---@param grep function
function Finder:run(live_grep, grep)
  -- 解析命令行工具
  self:parse()

  -- 生成最后的rg cmd
  table.insert(self.rg, "-- ") -- rg的命令格式，可以减少转义
  local cmd = table.concat(self.rg, " ")

  -- live_grep or grep
  local find = grep -- 默认使用grep
  if self.islive or not self.query or self.query == "" then
    find = live_grep
  end

  -- vim.print("query|" .. self.query .. "|")
  find(cmd, self.query, self.filepath)
end

M.build_rg_func = function(live_grep, grep)
  return function(args)
    Finder:new(args):run(live_grep, grep)
  end
end

return M
