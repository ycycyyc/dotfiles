-- require("bufferline").setup {
--     options = {
--         -- numbers = "buffer_id",
--         numbers = function(opts)
--             return string.format('%s:', (opts.id))
--         end,
--         -- number_style = 'none',
--         indicator_icon = "●●●",
--         buffer_close_icon = '',
--         close_icon = '',
--         show_buffer_icons = false,
--         left_trunc_marker = "left_trunc_marker",
--         right_trunc_marker = "right_trunc_marker",
--         modified_icon = 'X',
--         diagnostics = false
--     },
--     highlights = {buffer_selected = {guifg = "gray", guibg = 'white', gui = "bold,italic"}}
-- }
-- config for lua line

local M = {}
M.config = function()
  require("lualine").setup {
    options = {
      icons_enabled = false,
      theme = "onedark",
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {},
      always_divide_middle = true,
      globalstatus = false,
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff" },
      lualine_c = { "filename" },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      -- lualine_a = {},
      -- lualine_b = {},
      -- lualine_c = { "filename" },
      -- lualine_x = { "location" },
      -- lualine_y = {},
      -- lualine_z = {},
    },
    tabline = {
      lualine_a = { { "buffers", mode = 2 } },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = { { "diagnostics" } },
      lualine_z = { "tabs" },
    },
    extensions = { "fzf", "symbols-outline", "nvim-tree" },
  }
end

return M
