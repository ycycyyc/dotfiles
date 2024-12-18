local plugins = {
  blink = require "plugin.blink",
  cmp = require "plugin.cmp",
}
return plugins[YcVim.env.cmp]
