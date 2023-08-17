---@class Animal
---@field name string
local Animal = {}
Animal.__index = Animal

---@param name string
---@return Animal
function Animal.new(name)
  local self = {}
  setmetatable(self, Animal)
  self.name = name
  return self
end

function Animal:print()
  vim.print(self.name)
end

return Animal
