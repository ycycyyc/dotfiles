local keys = YcVim.keys

local cur_line_diff = function()
  local current_line = vim.api.nvim_get_current_line()
  local items = vim.fn.split(current_line) ---@type string[]

  -- TODO(yc) find git commit from line
  YcVim.git.commit_diff(items[1])
end

local function showFugitiveGit()
  if vim.fn.FugitiveHead() == "" then
    return
  end
  vim.cmd "G"
  vim.cmd "wincmd H"

  local line_count = vim.api.nvim_buf_line_count(0)
  local lines = vim.api.nvim_buf_get_lines(0, 0, line_count, true)

  local unstageline = line_count - 1
  local max_col = 80 -- 初始长度

  for l, text in ipairs(lines) do
    local n = string.len(text) + 12 -- TODO: 需要拿到signcolumn的长读
    if n > max_col then
      max_col = n
    end

    local match = string.match(text, "Unstaged")
    if match then
      unstageline = l
    end
  end

  if max_col > 100 then -- max
    max_col = 100
  end
  vim.cmd("vertical res " .. tostring(max_col))

  vim.fn.setcursorcharpos(unstageline + 1, 1)
end

local function toggleFugitiveGit()
  local winns = YcVim.util.get_winnums_byft "fugitive"
  local cur_win = vim.api.nvim_get_current_win()

  for _, winn in ipairs(winns) do
    --  当前所在的win刚好是futitive， 那么就close fugitive
    if cur_win == winn then
      vim.api.nvim_buf_delete(vim.fn.winbufnr(cur_win), { force = false })
      return
    end
  end

  if #winns == 0 then -- 没有打开futitive
    showFugitiveGit()
  else -- 直接跳转过去， 避免从头开始
    YcVim.util.try_jumpto_ft_win "fugitive"
  end
end

local fugitive_initfunc = function()
  YcVim.map.buf("n", "q", ":q<cr>")

  YcVim.map.buf("n", "<leader>d", function()
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
        YcVim.git.file_diff(items[2])
        return
      elseif syn.hl_group == "fugitiveHash" then
        cur_line_diff()
        return
      end
    end
  end)
end

local fugitiveblame_initfunc = function()
  YcVim.map.buf("n", "q", ":q<cr>")

  YcVim.map.buf("n", "<cr>", function()
    cur_line_diff()
  end)

  YcVim.map.buf("n", "<leader>d", function()
    cur_line_diff()
  end)
end

local plugin = {}

plugin.initfuncs = {
  { "fugitive", fugitive_initfunc },
  { "fugitiveblame", fugitiveblame_initfunc },
}

return {
  "tpope/vim-fugitive",
  keys = {
    { keys.git_blame, ":Git blame<cr>" },
    { keys.git_status, toggleFugitiveGit },
  },
  cmd = { "Gw" },
  config = function()
    YcVim.setup_plugin(plugin)
  end,
}
