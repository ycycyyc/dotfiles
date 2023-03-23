local M = {}

M.setup = function()
  vim.g.mapleader = " "

  local helper = require "utils.helper"
  local map = helper.build_keymap { noremap = true }

  map("n", "<Leader>w", ":w<cr>")
  map("n", "<Leader>q", ":q<CR>")
  map("n", "<Leader>m", "`")
  map("i", "jk", "<ESC>")
  map("i", "<c-f>", "<right>")

  map("n", "<Leader>[", ":bp<cr>")
  map("n", "<Leader>]", ":bn<cr>")

  map({ "n", "v" }, "H", "^")
  map({ "n", "v" }, "L", "$")

  map("n", "<BackSpace>", ":noh<cr>")

  map("v", "<", "<gv")
  map("v", ">", ">gv")

  map("n", "<c-d>", "10j")
  map("n", "<c-u>", "10k")

  map("i", "<c-a>", "<esc>I")

  map("n", "<C-Left>", ":vertical resize +2<cr>")
  map("n", "<C-Right>", ":vertical resize -2<cr>")
  map("n", "<C-Up>", ":resize +2<cr>")
  map("n", "<C-Down>", ":resize -2<cr>")
  map("v", "<bs>", "<esc>")

  -- map("i", "<c-e>", "<esc>A")
  map("i", "<c-e>", helper.i_move_to_end)
end

return M
