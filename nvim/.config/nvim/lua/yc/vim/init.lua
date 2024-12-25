YcVim = {}

setmetatable(YcVim, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("yc.vim." .. k)
    return rawget(t, k)
  end,
})

YcVim.extra = {}
YcVim.extra.env_hash = YcVim.util.calculateHash(vim.inspect(YcVim.env))
