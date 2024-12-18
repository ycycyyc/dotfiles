local cj = function()
  local npairs = require "nvim-autopairs"
  if vim.fn.pumvisible() ~= 0 then
    return npairs.esc "<c-j>" .. npairs.autopairs_cr()
  else
    return npairs.autopairs_cr()
  end
end

local plugin = {}

plugin.keymaps = {
  { "i", "<c-j>", cj, { expr = true, noremap = true, replace_keycodes = false } },
}

plugin.config = function()
  require("nvim-autopairs").setup { map_c_w = true }
  YcVim.setup_plugin(plugin)
end

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = plugin.config,
}
