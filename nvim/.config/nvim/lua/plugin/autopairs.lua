local cj = function()
  local npairs = require "nvim-autopairs"
  if vim.fn.pumvisible() ~= 0 then
    return npairs.esc "<c-j>" .. npairs.autopairs_cr()
  else
    return npairs.autopairs_cr()
  end
end

vim.keymap.set("i", "<c-j>", cj, { expr = true, noremap = true, replace_keycodes = false, buffer = true })

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    disable_filetype = { "snacks_input", "snacks_picker_input" },
    map_c_w = true,
  },
}
