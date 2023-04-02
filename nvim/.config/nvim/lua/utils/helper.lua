local M = {}

local api = vim.api

function M.buf_only()
  local cur = api.nvim_get_current_buf()
  local list = api.nvim_list_bufs()

  for _, i in pairs(list) do
    if vim.fn.buflisted(i) == 1 then
      if i ~= cur then
        api.nvim_buf_delete(i, { force = false })
      end
    end
  end
end

function M.diff_open()
  -- local reg_0_val = get_reg "0"
  vim.cmd("DiffviewOpen " .. vim.fn.getreg(0) .. "^!")
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

function M.get_visual_selection()
  local startp = vim.fn.getpos "v"
  startp = startp[2]
  local endp = vim.fn.getpos "."
  endp = endp[2]
  return { startp, endp }
end

function M.try_jumpto_qf_window()
  local wins = vim.api.nvim_list_wins()
  local qf_win
  for _, win_num in ipairs(wins) do
    local buf_num = vim.fn.winbufnr(win_num)
    local ft = vim.api.nvim_buf_get_option(buf_num, "filetype")
    if ft == "qf" then
      qf_win = win_num
      vim.api.nvim_set_current_win(qf_win)
      vim.cmd "redraw"
      return
    end
  end

  if qf_win == nil then
    print "no qf window found"
    return
  end
end

return M
