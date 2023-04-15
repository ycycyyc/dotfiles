local M = {}

M.setup = function()
  local keys = require "basic.keys"
  vim.g.mapleader = " "

  local helper = require "utils.helper"
  local map = helper.build_keymap { noremap = true }

  map("n", "<Leader>w", "<cmd>w<cr>")
  map("n", "<Leader>q", "<cmd>q<cr>")
  map("n", "<Leader>m", "`")
  map({ "i", "s"}, "jk", "<ESC>")
  -- map({ "t" }, "jk", "<c-\\><c-n>:q<cr>")

  map("i", "<c-f>", "<right>")

  map("n", "<Leader>[", "<cmd>bp<cr>")
  map("n", "<Leader>]", "<cmd>bn<cr>")

  map({ "n", "v" }, "H", "^")
  map({ "n", "v" }, "L", "$")

  map("n", "<BackSpace>", "<cmd>noh<cr>")

  map("v", "<", "<gv")
  map("v", ">", ">gv")

  map("n", "<c-d>", "10j")
  map("n", "<c-u>", "10k")

  map("i", "<c-a>", "<esc>I")

  map("n", "<C-Left>", "<cmd>vertical resize +2<cr>")
  map("n", "<C-Right>", "<cmd>vertical resize -2<cr>")
  map("n", "<C-Up>", "<cmd>resize +2<cr>")
  map("n", "<C-Down>", "<cmd>resize -2<cr>")
  map("v", "<bs>", "<esc>")

  map("i", "<c-e>", helper.i_move_to_end)

  map("n", keys.jump_to_qf, helper.try_jumpto_qf_window)
end

return M
