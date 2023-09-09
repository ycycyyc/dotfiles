-- fzf
local M = {}

local helper = require "utils.helper"
local keys = require "basic.keys"
local env = require("basic.env").env
local map = helper.build_keymap { noremap = true }

M.config = function()
  vim.env.FZF_DEFAULT_OPTS = "--layout=reverse"

  vim.g.fzf_preview_window = { "up:45%", "ctrl-/" }
  vim.g.fzf_layout = { window = { width = 0.8, height = 0.9 } }
  vim.g.fzf_commits_log_options =
    "--color --pretty=format:'%C(yellow)%h%Creset  %C(blue)<%an>%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s  %C(auto)%d'"

  vim.g.fzf_action = {
    ["ctrl-v"] = "vsplit",
    ["ctrl-s"] = "split",
  }

  map("n", keys.search_find_files, ":Files<cr>")
  map("n", keys.switch_buffers, ":Buffers<cr>")
  map("n", keys.search_cur_word_cur_buf, ":BLines <c-r><c-w><cr>")
  map("n", keys.cmd_history, ":History:<cr>")

  map("n", keys.git_commits, function()
    if require("yc.line.git").branch == "" then
      vim.notify "not in a git repo"
      return
    end

    local cmd = "git log -C " .. vim.g.fzf_commits_log_options

    local run = function()
      local options = {
        "--ansi",
        "--delimiter",
        ":",
        "--prompt",
        "Commits > ",
        "--multi",
      }

      local wrap = vim.fn["fzf#wrap"] { source = cmd, options = options }

      wrap["sink*"] = function(lists)
        local items = vim.fn.split(lists[2], " ")
        require("plug_conf.gitdiff").show_diff(items[1])
      end

      vim.fn["fzf#run"](wrap)
    end

    local ok, _ = pcall(run)
    if not ok then
      vim.cmd "run git cmd failed"
    end
  end)

  map("n", keys.search_buffer, function()
    local filename = vim.fn.fnameescape(vim.fn.expand "%:p")
    local line_count = vim.api.nvim_buf_line_count(0)

    if line_count > 2048 then
      vim.cmd.BLines()
      return
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, line_count, true)
    local items = {}
    for i, l in ipairs(lines) do
      table.insert(items, filename .. ":" .. tostring(i) .. ":1: " .. l)
    end

    local opt_preview = vim.fn["fzf#vim#with_preview"] "up:+{2}-/2"
    local options = {
      "--ansi",
      "--delimiter",
      ":",
      "--with-nth",
      "2..",
      "--prompt",
      tostring(line_count) .. " (lines) > ",
      "--expect",
      "ctrl-v", -- ignore
      "--bind",
      "alt-a:select-all,alt-d:deselect-all", -- ignore
      "--multi",
    }

    for _, o in ipairs(opt_preview["options"]) do
      table.insert(options, o)
    end

    local wrap = vim.fn["fzf#wrap"] { source = items, options = options }

    wrap["sink*"] = function(lists)
      local file = lists[2]

      local subs = vim.fn.split(file, ":")
      local row = tonumber(subs[2])

      vim.fn.setcursorcharpos(row, 1)
    end

    vim.fn["fzf#run"](wrap)
  end)

  vim.api.nvim_create_user_command("Rg", function(args)
    local rg = {
      "rg",
      "-H",
      "--hidden",
      "--column",
      "--line-number",
      "--no-heading",
      "--glob=!.git/",
      "--color=always",
      "--smart-case",
    }

    local fargs = args["fargs"]

    local suffix = ""
    local content = {}
    local ignore = 0
    local interactive = false
    for i, value in ipairs(fargs) do
      if ignore > 0 then
        ignore = 0
      elseif value == "-t" then
        ignore = 1
        if fargs[i + 1] == "go" then
          table.insert(rg, "-t go")
        elseif fargs[i + 1] == "cpp" then
          table.insert(rg, "-t cpp -t c")
        end
      elseif value == "--" then
        ignore = 1
        suffix = "-- " .. fargs[i + 1]
      elseif value == "-g" then
        ignore = 1
        table.insert(rg, "--glob='" .. fargs[i + 1] .. "'")
      elseif value == "-i" then
        interactive = true
      else
        table.insert(content, value)
      end
    end

    local preview_func = vim.fn["fzf#vim#with_preview"]
    local grep_func = vim.fn["fzf#vim#grep"]

    -- query content
    local contents = "'" .. table.concat(content, " ") .. "'"
    table.insert(rg, "-F")

    if #content == 0 or interactive then
      table.insert(rg, "-- ")
      local prefix = table.concat(rg, " ")

      local query = table.concat(content, " ")

      vim.fn["fzf#vim#grep2"](prefix, query, preview_func(), args["bang"])
      return
    end

    table.insert(rg, contents)

    -- suffix dir name
    if suffix ~= "" then
      table.insert(rg, suffix)
    end

    local preview = preview_func "up:45%"
    local rgcmd = table.concat(rg, " ")

    grep_func(rgcmd, 1, preview, args["bang"])
  end, { nargs = "*", bang = true })

  if not env.coc then
    map("n", keys.search_global, ":Rg<SPACE>")
    map("n", keys.search_cur_word, ":Rg <c-r><c-w><cr>")
  end
end

return M
