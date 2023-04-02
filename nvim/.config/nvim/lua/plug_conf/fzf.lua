-- fzf
local M = {}

local helper = require "utils.helper"
local keys = require "basic.keys"

local user_cmd_bind = vim.api.nvim_create_user_command
local user_cmd = function(name, cb)
  local opt = { nargs = "*", bang = true }
  user_cmd_bind(name, cb, opt)
end

local map = helper.build_keymap { noremap = true }

local fix_string = true
-- add --glob=!.git/ git ignore .git/
local rg_regex_cmd = "rg --column --line-number --no-heading --glob=!.git/ --color=always --smart-case "
local rg_fix_cmd = rg_regex_cmd .. " -F "

local rg_cmd_func = function()
  if fix_string == true then
    return rg_fix_cmd
  end
  return rg_regex_cmd
end

local toggle_rg_cmd_type = function()
  if fix_string == true then
    fix_string = false
    print "use rg_regix_cmd"
  else
    fix_string = true
    print "use rg_fix_cmd"
  end
end

local build_rg_func = function(opt)
  local preview_func = vim.fn["fzf#vim#with_preview"]
  local grep_func = vim.fn["fzf#vim#grep"]
  return function(args)
    if opt == nil then
      opt = { condition = "" }
    end

    local cmd
    if opt.rg_cmd_build ~= nil then
      cmd = opt.rg_cmd_build(args["args"])
    else
      cmd = string.format("%s %s -- '%s'", rg_cmd_func(), opt.condition, args["args"]) -- default build
    end

    local preview = preview_func()
    if args["bang"] ~= nil and args["bang"] == true then
      preview = preview_func "up:60%"
    end

    grep_func(cmd, 1, preview, args["bang"])
  end
end

local RgFzf = function(args)
  local preview_func = vim.fn["fzf#vim#with_preview"]
  local grep_func = vim.fn["fzf#vim#grep"]
  local query = args["args"]
  local prefix = rg_cmd_func() .. " -- "
  local init_cmd = prefix .. query .. " || true"
  local reload_cmd = prefix .. " {q} || true"

  local spec = { options = { "--phony", "--query", query, "--bind", "change:reload:" .. reload_cmd } }

  grep_func(init_cmd, 1, preview_func(spec), args["bang"])
end

M.config = function()
  map("n", keys.search_find_files, ":Files<cr>")
  map("n", keys.search_global, ":Rg!<SPACE>")
  map("n", keys.run_find, ":Find<space>")
  map("n", keys.search_buffer_preview, ":RgLines ")
  map("n", keys.search_buffer, ":BLines<cr>")
  map("n", keys.switch_buffers, ":Buffers<cr>")
  map("n", keys.search_toggle_rg_mode, toggle_rg_cmd_type)
  map("n", keys.search_git_grep, ":GitGrep ")

  user_cmd("Find", RgFzf)
  user_cmd("Rg", build_rg_func())
  user_cmd("Rghidden", build_rg_func { condition = "--hidden" })
  user_cmd("Rggo", build_rg_func { condition = "-t go" })
  user_cmd("Rgcpp", build_rg_func { condition = "-t cpp -t c" })
  user_cmd("Rgrust", build_rg_func { condition = "-t rust" })
  user_cmd("Rglua", build_rg_func { condition = "-t lua" })
  user_cmd("Rglines", function(args)
    local rg_cmd_build = function(word)
      local file_name = vim.fn.fnameescape(vim.fn.expand "%")
      if word == nil or word == "" then
        word = "."
      end
      local cmd = "rg --column --with-filename --line-number --no-heading --color=always --smart-case "
        .. word
        .. " "
        .. file_name
      return cmd
    end
    build_rg_func { rg_cmd_build = rg_cmd_build }(args)
  end)

  user_cmd("GitGrep", function(args)
    local cmd = "git grep -i --untracked --color=always --line-number --threads=8 -- " .. args["args"]
    local preview = vim.fn["fzf#vim#with_preview"] "up:60%"
    vim.fn["fzf#vim#grep"](cmd, 1, preview, args["bang"])
  end)

  vim.g.fzf_preview_window = { "up:40%", "ctrl-/" }

  -- " 让输入上方，搜索列表在下方
  vim.env.FZF_DEFAULT_OPTS = "--layout=reverse"

  vim.g.fzf_layout = { window = { width = 0.95, height = 0.85 } }
  vim.g.fzf_commits_log_options =
    "--color --pretty=format:'%C(yellow)%h%Creset  %C(blue)<%an>%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s  %C(auto)%d'"
end
return M
