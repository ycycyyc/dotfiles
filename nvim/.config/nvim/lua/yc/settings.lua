local helper = require "utils.helper"
local gotags = require "utils.gotags"
local keys = require "basic.keys"
local bmap = helper.build_keymap { noremap = true, buffer = true }

local au_group = vim.api.nvim_create_augroup
local au_cmd = vim.api.nvim_create_autocmd
local user_cmd = vim.api.nvim_create_user_command

local M = {}

local lua_file_cb = function()
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

  local file_grp = au_group("setting_ft", { clear = true })

  au_cmd("FileType", { pattern = { "lua" }, callback = lua_file_cb, group = file_grp })
  au_cmd("FileType", { pattern = { "qf" }, command = "wincmd J", group = file_grp })
  au_cmd("FileType", {
    pattern = { "go" },
    callback = function()
      bmap("n", keys.search_global, ":Rggo ")
    end,
    group = file_grp,
  })
  au_cmd("FileType", {
    pattern = { "h", "cpp", "hpp", "c" },
    callback = function()
      bmap("n", keys.switch_source_header, ":ClangdSwitchSourceHeader<cr>")
      bmap("n", keys.search_global, ":Rgcpp ")
    end,
    group = file_grp,
  })

  vim.keymap.set("n", keys.jump_to_qf, function()
    helper.try_jumpto_qf_window()
  end)

  user_cmd("DiffOpen", helper.diff_open, {})
  user_cmd("BufOnly", helper.buf_only, {})

  user_cmd("GoAddTags", function(args)
    gotags.add(args["args"])
  end, { nargs = "+" })

  user_cmd("GoRemoveTags", function(args)
    gotags.remove(args["args"])
  end, { nargs = "+" })

  user_cmd("TestCmd", function() end, { range = true })
end

return M
