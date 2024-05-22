local keys = require "basic.keys"
local helper = require "utils.helper"

local buf_map = function(mode, key, action)
  vim.keymap.set(mode, key, action, { noremap = true, buffer = true, silent = true })
end

local show_diff = function()
  local current_line = vim.api.nvim_get_current_line()
  local items = vim.fn.split(current_line) ---@type string[]

  -- TODO(yc) find git commit from line
  require("plug_conf.gitdiff").show_diff(items[1])
end

local function showFugitiveGit()
  if vim.fn.FugitiveHead() ~= "" then
    vim.cmd "G"
    vim.cmd "wincmd L"
  end
end

local function toggleFugitiveGit()
  if vim.fn.buflisted(vim.fn.bufname "fugitive:///*/.git//$") ~= 0 then
    -- local helper = require "utils.helper"

    --  如果当前window为fugitiv就关闭
    local winnums = helper.get_winnums_byft "fugitive"
    local cur_win = vim.api.nvim_get_current_win()
    for _, winn in ipairs(winnums) do
      if cur_win == winn then
        vim.cmd [[ execute ":bdelete" bufname('fugitive:///*/.git//$') ]]
        return
      end
    end

    require("utils.helper").try_jumpto_ft_win "fugitive"
  else
    showFugitiveGit()
  end
end

local fugitive_initfunc = function()
  buf_map("n", "q", ":q<cr>")

  buf_map("n", "<leader>d", function()
    local current_line = vim.api.nvim_get_current_line()
    local items = vim.fn.split(current_line)

    local unstaged_found = vim.fn.stridx(current_line, "Unstaged")
    if unstaged_found >= 0 then
      vim.notify "don't show Unstaged msg"
      return
    end

    local pos = vim.inspect_pos()
    if not pos.syntax then
      vim.notify "missing syntax field"
      return
    end

    for _, syn in ipairs(pos.syntax) do
      if syn.hl_group == "fugitiveUnstagedSection" then
        local cmd = "DiffviewOpen -- " .. items[2]
        vim.notify("Run cmd: " .. cmd)
        vim.cmd(cmd)
        return
      elseif syn.hl_group == "fugitiveHash" then
        show_diff()
        return
      end
    end
  end)
end

local fugitiveblame_initfunc = function()
  buf_map("n", "q", ":q<cr>")

  buf_map("n", "<cr>", function()
    show_diff()
  end)

  buf_map("n", "<leader>d", function()
    show_diff()
  end)
end

local M = {
  keymaps = {
    { "n", keys.git_blame, ":Git blame<cr>", {} },
    { "n", keys.git_status, toggleFugitiveGit, {} },
  },
  initfuncs = {
    { "fugitive", fugitive_initfunc },
    { "fugitiveblame", fugitiveblame_initfunc },
  },
}

M.config = function()
  helper.setup_m(M)
end

return M
