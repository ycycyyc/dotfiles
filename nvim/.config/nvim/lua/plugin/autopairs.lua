local helper = require "utils.helper"

local cj = function()
  local npairs = require "nvim-autopairs"
  if vim.fn.pumvisible() ~= 0 then
    return npairs.esc "<c-j>" .. npairs.autopairs_cr()
  else
    return npairs.autopairs_cr()
  end
end

local M = {
  keymaps = {
    { "i", "<c-j>", cj, { expr = true, noremap = true, replace_keycodes = false } },
  },
}

M.config = function()
  require("nvim-autopairs").setup { map_c_w = true }

  local cmp_autopairs = require "nvim-autopairs.completion.cmp"
  require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())

  helper.setup_m(M)
end

return M
