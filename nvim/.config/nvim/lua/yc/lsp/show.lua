local api = vim.api

---@class LspProgressWin
---@field bufid? number
---@field winid? number
---@field line string
---@field  new_buf_cnt number
---@field closed_cnt number
---@field redraw_cnt number
local M = {
  line = "",
  prepared = false,
  new_buf_cnt = 0,
  closed_cnt = 0,
  redraw_cnt = 0,
}

local vim_closing = false

local win_set_local_options = function(win, opts)
  api.nvim_win_call(win, function()
    for opt, val in pairs(opts) do
      local arg
      if type(val) == "boolean" then
        arg = (val and "" or "no") .. opt
      else
        arg = opt .. "=" .. val
      end
      vim.cmd("setlocal " .. arg)
    end
  end)
end

function M:prepare()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      vim_closing = true
      M:__close()
    end,
  })

  vim.api.nvim_create_user_command("ShowLspProgressStats", function()
    vim.print(string.format("new %d buf, close %d buf, redraw_cnt: %d", M.new_buf_cnt, M.closed_cnt, M.redraw_cnt))
  end, {})
end

---@param line string
function M:show(line)
  if vim_closing == true then
    return
  end

  if M.prepared == false then
    M:prepare()
    self.prepared = true
  end

  if self.line == "" and line ~= "" then
    self.redraw_cnt = self.redraw_cnt + 1
  end

  self.line = line

  local filetype = vim.api.nvim_buf_get_option(0, "filetype")
  if line == "" and filetype ~= "lua" then
    M:__close()
  else
    M:__show()
  end
end

---@param offset? number
function M:__show(offset)
  offset = offset or 0
  local height = 1
  local width = #self.line -- TODO
  if width == 0 then
    width = 1
  end

  local row, col = self:get_window_position(offset)
  local anchor = "SE"

  if self.bufid == nil or not api.nvim_buf_is_valid(self.bufid) then
    self.bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(self.bufid, "filetype", "lsp_progresss")
    vim.api.nvim_buf_set_option(self.bufid, "buflisted", false)
    M.new_buf_cnt = M.new_buf_cnt + 1
  end

  if self.winid == nil or not api.nvim_win_is_valid(self.winid) then
    self.winid = api.nvim_open_win(self.bufid, false, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      anchor = anchor,
      focusable = false,
      style = "minimal",
      noautocmd = true,
    })
  else
    api.nvim_win_set_config(self.winid, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      anchor = anchor,
    })
  end

  win_set_local_options(self.winid, {
    winblend = 100,
    winhighlight = "Normal:LspProgress",
  })

  api.nvim_buf_set_lines(self.bufid, 0, height, false, { self.line })
end

---@param offset number
---@return number
---@return number
function M:get_window_position(offset)
  local statusline_height = 0

  local laststatus = vim.opt.laststatus:get() ---@type number
  if laststatus == 2 or laststatus == 3 or (laststatus == 1 and #api.nvim_tabpage_list_wins() > 1) then
    statusline_height = 1
  end

  local height = vim.opt.lines:get() - (statusline_height + vim.opt.cmdheight:get())

  local width = vim.opt.columns:get()

  return (height - offset), width
end

function M:__close()
  M.closed_cnt = M.closed_cnt + 1
  if self.winid ~= nil and api.nvim_win_is_valid(self.winid) then
    api.nvim_win_hide(self.winid)
    self.winid = nil
  end
  if self.bufid ~= nil and api.nvim_buf_is_valid(self.bufid) then
    if self.bufid ~= api.nvim_get_current_buf() then
      api.nvim_buf_delete(self.bufid, { force = true })
    end
    self.bufid = nil
  end

  self.closed = true
end

return M
