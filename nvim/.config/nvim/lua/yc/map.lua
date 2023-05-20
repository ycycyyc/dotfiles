local M = {}

M.setup = function()
  local keys = require "basic.keys"
  vim.g.mapleader = " "

  local helper = require "utils.helper"
  local map = helper.build_keymap { noremap = true }

  map("n", "<Leader>w", "<cmd>w<cr>")
  map("n", "<Leader>q", "<cmd>q<cr>")
  map("n", "<Leader>m", "`")
  map({ "i", "s" }, "jk", "<ESC>")

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

  -- map("n", keys.jump_to_next_qf, helper.try_jumpto_next_item)
  -- map("n", keys.jump_to_prev_qf, helper.try_jumpto_prev_item)
  map("n", keys.jump_to_next_qf, "<cmd>cnext<cr>")
  map("n", keys.jump_to_prev_qf, "<cmd>cprev<cr>")

  map("c", "<A-b>", "<S-Left>")
  map({ "c", "i" }, "<A-f>", "<S-Right>")
  map("c", "<c-a>", "<Home>")
  map("c", "<c-e>", "<End>")
  map("c", "<c-f>", "<Right>")

  -- 交换内容，先删除内容1，再选中内容2，然后用<leader>x交换
  map("v", "<leader>x", "<ESC>`.``gvp``P")
  map("n", "<leader>x", "viw<ESC>`.``gvp``P<c-o>")

  map("v", "<leader>s", ":s/.*'\\(.*\\)'.*/\\1")
end

return M
