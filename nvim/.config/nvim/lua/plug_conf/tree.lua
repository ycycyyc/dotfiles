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
    git = { ignore = false },

    on_attach = function(bufnr)
      local api = require "nvim-tree.api"
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts "Prev Git")
      vim.keymap.set("n", "]c", api.node.navigate.git.next, opts "Next Git")
      vim.keymap.set("n", "<CR>", api.node.open.edit, opts "Open")
      vim.keymap.set("n", "o", api.node.open.edit, opts "Open")
      vim.keymap.set("n", "a", api.fs.create, opts "Create")
      vim.keymap.set("n", "<Tab>", api.node.open.preview, opts "Open Preview")
      vim.keymap.set("n", "r", api.fs.rename, opts "Rename")
      vim.keymap.set("n", "R", api.tree.reload, opts "Refresh")
      vim.keymap.set("n", "y", api.fs.copy.filename, opts "Copy Name")
      vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts "Open: Vertical Split")
      vim.keymap.set("n", "d", api.fs.remove, opts "Delete")
      vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts "Toggle Dotfiles")
      vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts "Toggle Git Ignore")
    end,
  }
  --
  vim.cmd [[highlight NvimTreeSymlink guifg=blue gui=bold,underline]]
end

return M
