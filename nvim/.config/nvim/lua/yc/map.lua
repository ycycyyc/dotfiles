local keys = YcVim.keys
vim.g.mapleader = " "
vim.g.maplocalleader = "<space>"

local map = function(mode, action, cb)
  vim.keymap.set(mode, action, cb, { noremap = true })
end

map("n", "<Leader>w", "<cmd>silent w<cr>")
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

map("i", "<c-e>", YcVim.util.i_move_to_end)

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

---@return boolean
local has_qf_win = function()
  local wins = YcVim.util.get_winnums_byft "qf"
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

-- smart deletion, dd
-- It solves the issue, where you want to delete empty line, but dd will override you last yank.
-- Code above will check if u are deleting empty line, if so - use black hole register.
-- [src: https://www.reddit.com/r/neovim/comments/w0jzzv/comment/igfjx5y/?utm_source=share&utm_medium=web2x&context=3]
local function smart_dd()
  if vim.api.nvim_get_current_line():match "^%s*$" then
    return '"_dd'
  else
    return "dd"
  end
end

vim.keymap.set("n", "dd", smart_dd, { noremap = true, expr = true })
