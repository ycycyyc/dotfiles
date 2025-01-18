---@class YcVim.rg
local rg = {}

---@type string[]
local rgCmdArgs = {
  "rg",
  "-H",
  "--hidden",
  "--column",
  "--line-number",
  "--no-heading",
  "--glob=!.git/",
  "--color=always",
  "--smart-case",
  "-F", --  regex = false
}

---@class YcVim.Finder
---@field islive boolean
---@field words string[]
---@field query string
---@field filepath string|nil
---@field fts string[]
local Finder = {}

---@param args table
---@return YcVim.Finder
function Finder:new(args)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.query = args["args"]
  self.words = args["fargs"]
  -- stylua: ignore
  self.filepath = nil
  self.islive = false
  self.fts = {}
  return o
end

---@type table<string, string[]>
local filetypes = {
  ["cpp"] = { "c", "cpp" },
  ["c"] = { "c", "cpp" },
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
      local filetype = self.words[index + 1] -- go cpp c lua or else

      local fts = filetypes[filetype]
      if fts == nil then
        table.insert(self.fts, filetype)
      else
        for _, ft in ipairs(fts) do
          table.insert(self.fts, ft)
        end
      end

      -- 后面再适配-t go 中间出现很多个空格的情况
      local match = string.match(self.query, "-t%s+" .. filetype)
      self.query = string.gsub(self.query, match, "")
      self.query = string.gsub(self.query, "%s+$", "") --删除最后面的空字符
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
      self.islive = true

      self.query = string.gsub(self.query, "%-i", "") -- TODO 如何避免删错了
      self.query = string.gsub(self.query, "%s+$", "") --删除最后面的空字符
    end,
  }

  for word, handler in pairs(handlers) do
    local exist, index = self:have(word)
    if exist then
      handler(index)
    end
  end

  if not self.query or self.query == "" then
    self.islive = true
  end
end

---@param live_grep fun(f: YcVim.Finder)
---@param grep fun(f: YcVim.Finder)
function Finder:run(live_grep, grep)
  -- 解析命令行工具
  self:parse()

  -- live_grep or grep
  local find = grep -- 默认使用grep
  if self.islive then
    find = live_grep
  end

  find(self)
end

---@return string
function Finder:cmd()
  local cmd = {} ---@type string[]

  for _, arg in ipairs(rgCmdArgs) do
    table.insert(cmd, arg)
  end

  -- 生成最后的rg cmd
  -- 文件名
  for _, ft in ipairs(self.fts) do
    table.insert(cmd, "-t")
    table.insert(cmd, ft)
  end

  return table.concat(cmd, " ")
end

---@param live_grep fun(f: YcVim.Finder)
---@param grep fun(f: YcVim.Finder)
---@return fun(args: table)
rg.run = function(live_grep, grep)
  return function(args)
    Finder:new(args):run(live_grep, grep)
  end
end

return rg
