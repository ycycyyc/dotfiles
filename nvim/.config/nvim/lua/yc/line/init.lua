local M = {}

M.setup = function()
  vim.opt.laststatus = 3
  vim.opt.showmode = false

  -- create statueline theme
  vim.cmd [[
      hi! StatusLineNormal ctermfg=145 ctermbg=237
      hi! StatusLineCurFile ctermfg=235 ctermbg=114 cterm=bold
      hi! StatusLineBufListNormal ctermfg=145 ctermbg=239
      hi! NumberBuffers ctermfg=235 ctermbg=39 cterm=bold

      hi! WinSeparator ctermbg=237

      hi! StatusNormalMode ctermfg=235 ctermbg=39 cterm=bold
      hi! StatusInsertMode ctermfg=235 ctermbg=204 cterm=bold
      hi! StatusTermMode ctermfg=235 ctermbg=180 cterm=bold
      hi! StatusVisMode ctermfg=235 ctermbg=173 cterm=bold
      hi! StatusVlMode ctermfg=235 ctermbg=173 cterm=bold
      hi! StatusSelMode ctermfg=235 ctermbg=200 cterm=bold
      hi! StatusCmdMode ctermfg=235 ctermbg=39 cterm=bold

      augroup nobuflisted
        autocmd!
        autocmd FileType qf set nobuflisted
        autocmd FileType fugitive set nobuflisted
      augroup END
  ]]

  local mode = require "yc.line.mode"
  mode.start()

  local nbuffers = require "yc.line.nbuffers"
  nbuffers.start()
  nbuffers.theme = "NumberBuffers"
  nbuffers.end_theme = "StatusLineNormal"

  local bufferlist = require "yc.line.bufferlist"
  bufferlist.start()
  bufferlist.sel_theme = "StatusLineCurFile"
  bufferlist.theme = "StatusLineBufListNormal"
  bufferlist.end_theme = "StatusLineNormal"

  ---@return number
  local max_width = function()
    return vim.o.columns - mode.width() - nbuffers.width() - 10
  end

  bufferlist.max_width_cb = max_width
  bufferlist.nbuffers_cb = nbuffers.update

  function _G.yc_statusline()
    return mode.to_string() .. "%=" .. bufferlist.to_string() .. "%=" .. nbuffers.to_string()
  end

  vim.opt.statusline = "%!v:lua.yc_statusline()"

  vim.api.nvim_create_user_command("ShowStatuslineStat", function()
    vim.print(string.format("[StatusLine] %s %s %s", mode.metrics(), nbuffers.metrics(), bufferlist.metrics()))
  end, {})
end

return M
