local M = {}

M.setup = function()
  local keys = require "basic.keys"
  vim.g.mapleader = " "

  local helper = require "utils.helper"
  local map = helper.build_keymap { noremap = true }
  local slient_map = helper.build_keymap { noremap = true, silent = true }

  slient_map("n", "<Leader>w", "<cmd>silent w<cr>")
  map("n", "<Leader>q", "<cmd>q<cr>")
  map("n", "<Leader>m", "`")
  map({ "i", "s" }, "jk", "<ESC>")

  map("i", "<c-f>", "<right>")

  map("n", "<Leader>[", "<cmd>bp<cr>")
  map("n", "<Leader>]", "<cmd>bn<cr>")

  map("n", "]t", "<cmd>tabNext<cr>")
  map("n", "[t", "<cmd>tabprevious<cr>")

  map({ "n", "x" }, "H", "^")
  map({ "n", "x" }, "L", "$")

  map("n", "<BackSpace>", "<cmd>noh<cr>")

  map("x", "<", "<gv")
  map("x", ">", ">gv")

  map("n", "<c-d>", "10j")
  map("n", "<c-u>", "10k")

  map("i", "<c-a>", "<esc>I")

  map("n", "<C-Left>", "<cmd>vertical resize +2<cr>")
  map("n", "<C-Right>", "<cmd>vertical resize -2<cr>")
  map("n", "<C-Up>", "<cmd>resize +2<cr>")
  map("n", "<C-Down>", "<cmd>resize -2<cr>")
  map("x", "<bs>", "<esc>")

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
  -- map("x", "<leader>x", "<ESC>`.``gvp``P")
  -- map("n", "<leader>x", "viw<ESC>`.``gvp``P<c-o>")

  map("x", "<leader>s", ":s/.*'\\(.*\\)'.*/\\1")

  local mouseEnable = false ---@type boolean
  map("n", keys.toggle_mouse, function()
    if mouseEnable == false then
      vim.opt.mouse = "nv"
      mouseEnable = true
      vim.print "set mouse=nv"
      return
    end

    vim.opt.mouse = ""
    mouseEnable = false
    vim.print "set mouse="
  end)

  local get_winnums_byft = require("utils.helper").get_winnums_byft

  ---@return boolean
  local has_qf_win = function()
    local wins = get_winnums_byft "qf"
    return #wins > 0
  end

  map("n", keys.jump_to_next_qf, function()
    if has_qf_win() then
      local ok, _ = pcall(vim.cmd.cnext)
      if not ok then
        vim.cmd.cfirst()
      end
    end
  end)

  map("n", keys.jump_to_prev_qf, function()
    if has_qf_win() then
      local ok, _ = pcall(vim.cmd.cprev)
      if not ok then
        vim.cmd.clast()
      end
    end
  end)

  map("s", "<Del>", [[<c-g>c]])
  map("s", "<BS>", [[<c-g>c]])

  map("n", "<leader>1", "1<c-w>w")
  map("n", "<leader>2", "2<c-w>w")
  map("n", "<leader>3", "3<c-w>w")
  map("n", "<leader>4", "4<c-w>w")
  map("n", "<leader>5", "5<c-w>w")
  map("n", "<leader>6", "6<c-w>w")
  map("n", "<leader>7", "7<c-w>w")
end

return M
