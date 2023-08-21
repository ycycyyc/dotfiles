local utils = require "yc.line.utils"

local redraw = function() end
local redrawCnt = 0

local M = {}

local L = {
  cached_content = utils.add_theme("StatusLineTotalLine", " %l of %L ", "StatusLineNormal"),
}

L.to_string = function()
  return L.cached_content
end

L.width = function()
  return utils.evaluates_width(L.cached_content)
end

M.setup = function()
  vim.opt.laststatus = 3
  vim.opt.showmode = false

  vim.cmd [[
      augroup nobuflisted
        autocmd!
        autocmd FileType qf set nobuflisted
        autocmd FileType fugitive set nobuflisted
      augroup END
  ]]

  local mode = require "yc.line.mode"
  mode.start()

  local git = require "yc.line.git"
  git.theme = "StatusLineBufListNormal"
  git.end_theme = "StatusLineNormal"
  git.start()

  local nbuffers = require "yc.line.nbuffers"
  nbuffers.theme = "NumberBuffers"
  nbuffers.end_theme = "StatusLineNormal"
  nbuffers.start()

  local bufferlist = require "yc.line.bufferlist"
  bufferlist.sel_theme = "StatusLineCurFile"
  bufferlist.theme = "StatusLineBufListNormal"
  bufferlist.end_theme = "StatusLineNormal"
  bufferlist.start()

  ---@return number
  local max_width = function()
    return vim.o.columns - mode.width() - nbuffers.width() - L.width() - git.width() - 10
  end

  bufferlist.max_width_cb = max_width
  bufferlist.nbuffers_cb = nbuffers.update

  function _G.yc_statusline()
    return mode.to_string()
      .. git.to_string()
      .. "%="
      .. bufferlist.to_string()
      .. "%="
      .. L.to_string()
      .. nbuffers.to_string()
  end

  redraw = function()
    redrawCnt = redrawCnt + 1
    bufferlist.refresh()
    vim.opt.statusline = "%!v:lua.yc_statusline()"
  end
  redraw()

  vim.api.nvim_create_autocmd("User", {
    pattern = "LineRefresh",
    callback = function()
      vim.schedule(function()
        redraw()
      end)
    end,
  })

  vim.api.nvim_create_user_command("ShowStatuslineStats", function()
    vim.print(
      string.format(
        "[StatusLine] %s %s %s %s %s",
        mode.metrics(),
        git.metrics(),
        nbuffers.metrics(),
        bufferlist.metrics(),
        string.format("[redrawCnt: %d ]", redrawCnt)
      )
    )
  end, {})
end

return M
