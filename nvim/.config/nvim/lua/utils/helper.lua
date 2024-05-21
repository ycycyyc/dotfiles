local M = {}

local api = vim.api

function M.buf_only()
  ---@type number
  local cur = api.nvim_get_current_buf()

  ---@type number[]
  local list = api.nvim_list_bufs()

  for _, i in ipairs(list) do
    if vim.fn.buflisted(i) == 1 then
      if i ~= cur then
        api.nvim_buf_delete(i, { force = false })
      end
    end
  end
end

function M.diff_open()
  vim.cmd("DiffviewOpen " .. vim.fn.getreg "0" .. "^!")
end

function M.build_keymap(opts)
  return function(mode, action, cb)
    vim.keymap.set(mode, action, cb, opts)
  end
end

function M.nnoremap()
  return function(action, cb)
    vim.keymap.set("n", action, cb, { noremap = true })
  end
end

function M.i_move_to_end()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("A", true, false, true), "n", true)
end

---@return number[]
function M.get_visual_selection()
  ---@type number[] | number
  local startp = vim.fn.getpos "v" -- len == 4
  startp = startp[2]

  ---@type number[] | number
  local endp = vim.fn.getpos "." -- len == 4
  endp = endp[2]

  return { startp, endp }
end

---@param wanted string
---@return number[]
function M.get_winnums_byft(wanted)
  local win_nums = {}
  local wins = vim.api.nvim_list_wins()
  for _, win_num in ipairs(wins) do
    local buf_num = vim.fn.winbufnr(win_num)
    local ft = vim.api.nvim_buf_get_option(buf_num, "filetype")
    if ft == wanted then
      table.insert(win_nums, win_num)
    end
  end
  return win_nums
end

---@param wanted string
---@return boolean
function M.try_jumpto_ft_win(wanted)
  local win_nums = M.get_winnums_byft(wanted)

  if #win_nums == 0 then
    vim.print("no " .. wanted .. " window found")
    return false
  end

  -- jump first window
  vim.api.nvim_set_current_win(win_nums[1])
  vim.cmd "redraw"
  return true
end

function M.try_jumpto_next_item()
  local succ = M.try_jumpto_ft_win "qf"
  if succ == true then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("j", true, false, true), "n", true)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, false, true), "n", true)
  end
end

function M.try_jumpto_prev_item()
  local succ = M.try_jumpto_ft_win "qf"
  if succ == true then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("k", true, false, true), "n", true)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, false, true), "n", true)
  end
end

function M.win_only()
  local cur_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_list_wins()
  if #wins <= 1 then
    return
  end
  for _, win in ipairs(wins) do
    if win ~= cur_win then
      vim.api.nvim_win_close(win, true)
    end
  end
end

---@param major number
---@param minor number?
---@param patch number?
---@return boolean
function M.since_nvim(major, minor, patch)
  minor = minor or 0
  patch = patch or 0

  local v = vim.version()
  if v.major > major then
    return true
  end
  if v.major == major then
    if v.minor > minor then
      return true
    end
    if v.minor == minor then
      if v.patch >= patch then
        return true
      end
    end
  end

  return false
end

---@param user_cmds table
function M.setup_usercmd(user_cmds)
  for _, user_cmd in ipairs(user_cmds) do
    vim.api.nvim_create_user_command(user_cmd[1], user_cmd[2], user_cmd[3])
  end
end

---@param keymaps table
function M.setup_keymaps(keymaps)
  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3], keymap[4])
  end
end

return M
