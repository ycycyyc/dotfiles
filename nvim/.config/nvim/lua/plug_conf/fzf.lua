-- fzf
local M = {}

local helper = require "utils.helper"
local keys = require "basic.keys"
local env = require("basic.env").env
local map = helper.build_keymap { noremap = true }

M.config = function()
  vim.env.FZF_DEFAULT_OPTS = "--layout=reverse"

  vim.g.fzf_preview_window = { "up:40%", "ctrl-/" }
  vim.g.fzf_layout = { window = { width = 0.95, height = 0.85 } }
  vim.g.fzf_commits_log_options =
    "--color --pretty=format:'%C(yellow)%h%Creset  %C(blue)<%an>%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s  %C(auto)%d'"

  map("n", keys.search_find_files, ":Files<cr>")
  map("n", keys.search_buffer, ":BLines<cr>")
  map("n", keys.switch_buffers, ":Buffers<cr>")
  map("n", keys.search_cur_word_cur_buf, ":BLines <c-r><c-w><cr>")
  map("n", keys.git_commits, ":Commits<cr>")

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
    -- contents
    table.insert(rg, "-F")
    if #content == 0 or interactive then
      local query = ""
      local show_query = ""
      if #content >= 1 then
        query = table.concat(content, " ")
        show_query = query
      end

      if #content > 1 then
        query = "'" .. query .. "'"
      end

      table.insert(rg, "-- ")

      local prefix = table.concat(rg, " ")

      local init_cmd = prefix .. query .. " || true"
      local reload_cmd = prefix .. " {q} || true"
      local spec = { options = { "--phony", "--query", show_query, "--bind", "change:reload:" .. reload_cmd } }
      grep_func(init_cmd, 1, preview_func(spec), args["bang"])
      return
    end

    table.insert(rg, contents)

    -- suffix dir name
    if suffix ~= "" then
      table.insert(rg, suffix)
    end

    local preview = preview_func "up:60%"
    local rgcmd = table.concat(rg, " ")

    grep_func(rgcmd, 1, preview, args["bang"])
  end, { nargs = "*", bang = true })

  if not env.coc then
    map("n", keys.search_global, ":Rg<SPACE>")
    map("n", keys.search_cur_word, ":Rg <c-r><c-w><cr>")
  end
end

return M
