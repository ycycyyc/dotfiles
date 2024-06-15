local keys = require "basic.keys"
local helper = require "utils.helper"

local M = {
  keymaps = {
    {
      "n",
      keys.toggle_dir,
      "<cmd>NvimTreeToggle<cr>",
      {},
    },
    {
      "n",
      keys.toggle_dir_open_file,
      function()
        require("nvim-tree.api").tree.open { find_file = true }
      end,
      {},
    },
  },
}

local w_padding = 30
local h_padding = 2

M.config = function()
  require("nvim-tree").setup {
    sort_by = "case_sensitive",
    renderer = {
      root_folder_label = false,
      add_trailing = false,
      group_empty = true,
      indent_markers = { enable = true },
      icons = {
        padding = " ",
        show = { file = false, folder = false, folder_arrow = true, git = true },
        glyphs = { folder = { arrow_closed = "▸", arrow_open = "▾" } },
      },
    },
    view = {
      float = {
        enable = true,
        open_win_config = function()
          return {
            border = "rounded",
            relative = "editor",
            width = vim.o.columns - 2 * w_padding,
            height = vim.o.lines - 2 * h_padding - 4, -- 4是winbar statusline的高度
            row = h_padding,
            col = w_padding,
            noautocmd = true,
          }
        end,
      },
    },
    filters = {
      dotfiles = false,
      custom = { "^.git$" },
    },
    git = {
      ignore = false,
    },

    on_attach = function(bufnr)
      local api = require "nvim-tree.api"
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      vim.keymap.set("n", "[c", api.node.navigate.git.prev_skip_gitignored, opts "Prev Git")
      vim.keymap.set("n", "]c", api.node.navigate.git.next_skip_gitignored, opts "Next Git")
      vim.keymap.set("n", "<c-l>", api.node.open.edit, opts "Open")
      vim.keymap.set("n", "<c-h>", api.node.navigate.parent_close, opts "Close Directory")
      vim.keymap.set("n", "<CR>", api.node.open.edit, opts "Open")
      vim.keymap.set("n", "a", api.fs.create, opts "Create")
      vim.keymap.set("n", "<Tab>", api.node.open.edit, opts "Open")
      vim.keymap.set("n", "r", api.fs.rename_full, opts "rename: full path")
      vim.keymap.set("n", "R", api.fs.rename_sub, opts "rename: sub")
      vim.keymap.set("n", "<c-r>", api.tree.collapse_all, opts "collapse_all")
      vim.keymap.set("n", "<c-o>", api.tree.collapse_all, opts "collapse_all")
      vim.keymap.set("n", "y", api.fs.copy.filename, opts "Copy Name")
      vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts "Open: Vertical Split")
      vim.keymap.set("n", "d", api.fs.remove, opts "Delete")

      vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts "Next Sibling")
      vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts "Previous Sibling")

      vim.keymap.set("n", "th", api.tree.toggle_hidden_filter, opts "Toggle Dotfiles")
      vim.keymap.set("n", "ti", api.tree.toggle_gitignore_filter, opts "Toggle Git Ignore")
      vim.keymap.set("n", "q", api.tree.close, opts "Close the tree")

      vim.api.nvim_create_autocmd("CursorMoved", {
        group = vim.api.nvim_create_augroup("show_dir_nvim_tree", { clear = true }),
        buffer = bufnr,
        callback = function(args)
          local node = api.tree.get_node_under_cursor()
          local winid = vim.api.nvim_get_current_win()

          local bufid = vim.fn.winbufnr(winid)
          if bufid ~= bufnr then
            vim.notify "buf err" -- should never happen
            return
          end

          local cur_dir = vim.fn.getcwd()

          local set = function(title)
            if title == "" then
              title = string.format(" %s ", cur_dir)
            else
              title = string.format(" %s ▸ %s ", cur_dir, title)
            end
            local config = vim.api.nvim_win_get_config(winid)
            local new_config = vim.tbl_deep_extend("force", config, {
              title = title,
            })
            vim.api.nvim_win_set_config(winid, new_config)
          end

          if not node or not node.parent or not node.parent.absolute_path then
            set ""
            return
          end

          if cur_dir == node.parent.absolute_path then
            set ""
            return
          end

          local path = vim.fn.fnamemodify(node.parent.absolute_path, ":~:.")
          set(path)
        end,
      })
    end,
  }

  helper.setup_m(M)
end

return M
