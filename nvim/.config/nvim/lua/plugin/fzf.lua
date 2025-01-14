local keys = YcVim.keys

local search_buf = function()
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

-- stylua: ignore
  local options = {
    "--ansi", "--delimiter", ":", "--with-nth", "2..",
    "--prompt", tostring(line_count) .. " (lines) > ",
    "--expect", "ctrl-v", -- ignore
    "--bind", "alt-a:select-all,alt-d:deselect-all", -- ignore
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

    if row then
      vim.fn.setcursorcharpos(row, 1)
    end
  end

  vim.fn["fzf#run"](wrap)
end

local git_commit = function()
  local head = YcVim.git.head()
  if head == "" then
    vim.notify "not in a git repo"
    return
  end

  local cmd = "git log -C " .. vim.g.fzf_commits_log_options

  local run = function()
    local options = { "--ansi", "--delimiter", ":", "--prompt", "Commits > ", "--multi" }
    local wrap = vim.fn["fzf#wrap"] { source = cmd, options = options }

    wrap["sink*"] = function(lists)
      local items = vim.fn.split(lists[2], " ")
      YcVim.git.commit_diff(items[1])
    end

    vim.fn["fzf#run"](wrap)
  end

  local ok, _ = pcall(run)
  if not ok then
    vim.cmd "run git cmd failed"
  end
end

local preview_func = vim.fn["fzf#vim#with_preview"]
local grep_func = vim.fn["fzf#vim#grep"]

local grep = function(cmd, query, filepath)
  local preview = preview_func "up:45%"
  -- -F处理下转义的问题
  local rgcmd = string.format("%s -F '%s'", cmd, query)
  if type(filepath) == "string" then
    rgcmd = string.format("%s -- %s", rgcmd, filepath)
  end
  grep_func(rgcmd, 1, preview, false)
end

local live_grep = function(cmd, query, filepath)
  local prefix = string.format("%s -F", cmd)
  -- TODO:后面再想办法处理指定路径的情况
  -- if type(filepath) == "string" then
  --   prefix = string.format("%s -- %s", prefix, filepath)
  -- end
  vim.fn["fzf#vim#grep2"](prefix, query, preview_func(), false)
end

-- fzf
local M = {
  user_cmds = {
    {
      "Rg",
      YcVim.rg.run(live_grep, grep),
      { nargs = "*", bang = true },
    },
  },
  keymaps = {
    { "n", keys.pick_files, ":Files<cr>", { noremap = true } },
    { "n", keys.pick_buffers, ":Buffers<cr>", { noremap = true } },
    { "n", keys.pick_grep_word_cur_buf, ":BLines <c-r><c-w><cr>", { noremap = true } },
    { "n", keys.pick_cmd_history, ":History:<cr>", { noremap = true } },
    { "n", keys.git_commits, git_commit, { noremap = true } },
    { "n", keys.pick_lines, search_buf, { noremap = true } },
  },
}

M.config = function()
  vim.env.FZF_DEFAULT_OPTS = "--layout=reverse" .. ' --bind "alt-a:select-all,alt-d:deselect-all"'

  vim.g.fzf_preview_window = { "up:45%", "ctrl-/" }
  vim.g.fzf_layout = { window = { width = 0.8, height = 0.9 } }
  vim.g.fzf_commits_log_options =
    "--color --pretty=format:'%C(yellow)%h%Creset  %C(blue)<%an>%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s  %C(auto)%d'"

  vim.g.fzf_action = {
    ["ctrl-v"] = "vsplit",
    ["ctrl-s"] = "split",
  }

  YcVim.setup(M)
end

return M
