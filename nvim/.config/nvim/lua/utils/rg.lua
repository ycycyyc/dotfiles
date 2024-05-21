local M = {}

---@class Yc.Finder
---@field rg string[]
---@field islive boolean|nil
---@field query string
---@field words string[]
---@field filepath string|nil
local Finder = {}

---@param args table
---@return Yc.Finder
function Finder:new(args)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.query = args["args"]
  self.words = args["fargs"]
  -- stylua: ignore
  self.rg = { "rg", "-H", "--hidden", "--column", "--line-number", "--no-heading", "--glob=!.git/", "--color=always", "--smart-case" }
  self.filepath = nil
  return o
end

local types_mapping = {
  ["cpp"] = "-t cpp -t c",
  ["c"] = "-t cpp -t c",
  ["go"] = "-t go",
  ["lua"] = "-t lua",
  ["rust"] = "-t rust",
}

---@param wanted_word string
---@return boolean
---@return integer
function Finder:have(wanted_word)
  for index, word in ipairs(self.words) do
    if word == wanted_word then
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
      if index == #self.words then
        return
      end

      -- -t 后面的那个元素
      local val_after_t = self.words[index + 1] -- go cpp c lua or else

      for _type, _t_type in pairs(types_mapping) do
        if _type == val_after_t then
          table.insert(self.rg, _t_type)

          -- 后面再适配-t go 中间出现很多个空格的情况
          local match = string.match(self.query, "-t%s+" .. _type)
          self.query = string.gsub(self.query, match, "")
          self.query = string.gsub(self.query, "%s+$", "") --删除最后面的空字符
        end
      end
    end,
    ["--"] = function(index)
      -- 最后一个提前退出
      if index == #self.words then
        return
      end

      self.filepath = self.words[index + 1]
      self.query = string.gsub(self.query, "%-%-", "") -- TODO 如何避免删错了
      self.query = string.gsub(self.query, self.words[index + 1], "")
      self.query = string.gsub(self.query, "%s+$", "") --删除最后面的空字符
    end,
    ["-i"] = function(_)
      self.query = string.gsub(self.query, "%-i", "") -- TODO 如何避免删错了
      self.query = string.gsub(self.query, "%s+$", "") --删除最后面的空字符
      self.islive = true
    end,
  }

  for word, handler in pairs(handlers) do
    local exist, index = self:have(word)
    if exist then
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
