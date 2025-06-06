vim.opt.encoding = "UTF-8"
vim.opt.cmdheight = 1

vim.opt.nu = true
vim.opt.rnu = true

vim.opt.colorcolumn = "100"
vim.opt.mouse = ""
vim.opt.ignorecase = true -- 大小写忽略
vim.opt.smartcase = true

vim.opt.updatetime = 300 -- ? what
vim.opt.wildignorecase = true
vim.opt.hidden = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.shortmess = vim.opt.shortmess + "c" + "s" -- 简写
vim.opt.scrolloff = 1 -- 滚动时， 底部留俩行

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.sw = 4

-- 在插入模式下，会把按 Tab 键所插入的 tab 字符替换为合适数目的空格。
-- 如果确实要插入 tab 字符，需要按 CTRL-V 键，再按 Tab 键
vim.opt.expandtab = true

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.signcolumn = "yes:2"

vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

vim.opt.guicursor = "n-v-c-i:block"
vim.opt.splitright = true

-- 分割线出掉白线
vim.opt.fillchars = "vert: ,horiz: ,horizdown: ,verthoriz: ,vertleft: ,vertright: "

-- :100 只保留100条history cmd
vim.opt.shada:append ":100"

vim.opt.laststatus = 3
vim.opt.showmode = false

vim.opt.syntax = "off"
