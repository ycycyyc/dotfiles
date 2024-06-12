local utils = require "utils.theme"

local M = {
  cached_str = utils.add_theme("StatusLineTotalLine", " %l of %L ", "StatusLineNormal"),
}

return M
