---@class YcVim
---@field git YcVim.git
---@field env YcVim.env
---@field util YcVim.util
---@field lsp YcVim.lsp
---@field keys YcVim.keys
---@field rg YcVim.rg
---@field colors YcVim.colors
---@field lazy YcVim.lazy
---@field cmp YcVim.cmp
---@field extra YcVim.extra
---@field setup fun(m: YcVim.SetupOpt)
---@field env_hash number
YcVim = {}

setmetatable(YcVim, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("yc.vim." .. k)
    return rawget(t, k)
  end,
})


---@type number
YcVim.env_hash = YcVim.util.calculateHash(vim.inspect(YcVim.env))
