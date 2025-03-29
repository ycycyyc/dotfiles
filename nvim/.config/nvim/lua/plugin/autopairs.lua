local cj = function()
  local npairs = require "nvim-autopairs"
  if YcVim.cmp.visible() then
    YcVim.cmp.hide()
  end
  return npairs.autopairs_cr()
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
