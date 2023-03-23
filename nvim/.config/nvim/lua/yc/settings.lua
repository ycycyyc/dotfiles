local helper = require "utils.helper"
local gotags = require "utils.gotags"
local keys = require "basic.keys"

local au_group = vim.api.nvim_create_augroup
local au_cmd = vim.api.nvim_create_autocmd
local user_cmd = vim.api.nvim_create_user_command
local map = helper.build_keymap { noremap = true, buffer = 0 }

local M = {}

local go_file_cb = function()
  map("n", keys.search_global, ":RgGo<SPACE>")
end

local cpp_file_cb = function()
  map("n", keys.search_global, ":RgCpp<SPACE>")
  map("n", keys.switch_source_header, ":ClangdSwitchSourceHeader<cr>")
end

local c_file_cb = function()
  map("n", keys.search_global, ":RgC<SPACE>")
  map("n", keys.switch_source_header, ":ClangdSwitchSourceHeader<cr>")
end

local normal_file_cb = function()
  map("n", keys.search_global, ":RgHidden<SPACE>")
  map("n", keys.search_find_files, ":GitFiles<cr>")
end

local lua_file_cb = function()
  normal_file_cb()

  vim.opt.tabstop = 2
  vim.opt.softtabstop = 2
  vim.opt.sw = 2
  vim.opt.expandtab = true -- 在插入模式下，会把按 Tab 键所插入的 tab 字符替换为合适数目的空格。如果确实要插入 tab 字符，需要按 CTRL-V 键，再按 Tab 键

  local stylua_exist
  local function format()
    if stylua_exist == true then
      require("stylua").format()
    elseif stylua_exist == false then
      -- donothing
    else
      stylua_exist = vim.fn.executable "stylua" == 1
      format()
    end
  end
  user_cmd("Format", format, {})
end

M.setup = function()
  -- Highlight on yank
  local yank_grp = au_group("YankHighlight", { clear = true })
  au_cmd("TextYankPost", {
    callback = function()
      vim.highlight.on_yank { timeout = 300 }
    end,
    group = yank_grp,
  })

  local file_grp = au_group("t_filetype_grp", { clear = true })
  -- au_cmd("BufWritePre", { pattern = { "*.go" }, callback = tool.format, group = file_grp })
  -- au_cmd("BufWritePre", { pattern = { "*.lua" }, callback = tool.cmd_func "Format", group = file_grp })

  au_cmd("FileType", { pattern = { "go" }, callback = go_file_cb, group = file_grp })
  au_cmd("FileType", { pattern = { "h", "cpp", "hpp" }, callback = cpp_file_cb, group = file_grp })
  au_cmd("FileType", { pattern = { "c" }, callback = c_file_cb, group = file_grp })
  au_cmd("FileType", { pattern = { "vim", "NvimTree" }, callback = normal_file_cb, group = file_grp })
  au_cmd("FileType", { pattern = { "lua" }, callback = lua_file_cb, group = file_grp })
  au_cmd("FileType", { pattern = { "qf" }, command = "wincmd J" })

  user_cmd("DiffOpen", helper.diff_open, {})
  user_cmd("BufOnly", helper.buf_only, {})

  user_cmd("GoAddTags", function(args)
    gotags.add(args["args"])
  end, { nargs = "+" })

  user_cmd("GoRemoveTags", function(args)
    gotags.remove(args["args"])
  end, { nargs = "+" })

  user_cmd("TestCmd", function()
  end, { range = true })
end

return M
