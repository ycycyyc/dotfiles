local M = {}

M.config = function()
  require("nvim-tree").setup {
    sort_by = "case_sensitive",
    view = { adaptive_size = true, mappings = { list = { { key = "u", action = "dir_up" } } } },
    renderer = {
      add_trailing = false,
      group_empty = true,
      indent_markers = { enable = true },
      icons = {
        padding = " ",
        show = { file = false, folder = false, folder_arrow = true, git = true },
        glyphs = { folder = { arrow_closed = "▸", arrow_open = "▾" } },
      },
    },
    filters = { dotfiles = false },
  }
  --
  vim.cmd [[highlight NvimTreeSymlink guifg=blue gui=bold,underline]]
end

return M
