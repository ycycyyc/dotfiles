YcVim = {}

setmetatable(YcVim, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("yc.vim." .. k)
    return rawget(t, k)
  end,
})

YcVim.extra = {}

local function calculateHash(str)
  local hash = 0
  local len = string.len(str)
  for i = 1, len do
    local byte = string.byte(str, i)
    hash = (hash * 31 + byte) % (2 ^ 32) -- 使用简单的哈希算法
  end
  return hash
end

YcVim.extra.env_hash = calculateHash(vim.inspect(YcVim.env))
