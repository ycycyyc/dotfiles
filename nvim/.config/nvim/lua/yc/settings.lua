local au_group = vim.api.nvim_create_augroup
local au_cmd = vim.api.nvim_create_autocmd

local M = {
  ft_cbs = {},
}

M.register_fts_cb = function(fts, callback)
  if type(fts) == "string" then
    fts = { fts }
  end

  local register_ft_cb = function(ft)
    if M.ft_cbs[ft] == nil then
      M.ft_cbs[ft] = {}
    end
    table.insert(M.ft_cbs[ft], callback)

    local filetype = vim.api.nvim_buf_get_option(0, "filetype")
    if filetype == ft then
      callback()
    end
  end

  for _, ft in ipairs(fts) do
    register_ft_cb(ft)
  end

  -- refresh
  local file_grp = au_group("setting_ft", { clear = true })

  for ft, _ in pairs(M.ft_cbs) do
    au_cmd("FileType", {
      pattern = { ft },
      callback = function()
        for _, cb in ipairs(M.ft_cbs[ft]) do
          cb()
        end
      end,
      group = file_grp,
    })
  end
end

M.setup = function()
  local yank_grp = au_group("YankHighlight", { clear = true })
  au_cmd("TextYankPost", {
    callback = function()
      vim.highlight.on_yank { timeout = 300 }
    end,
    group = yank_grp,
  })

  local helper = require "utils.helper"

  M.register_fts_cb("lua", function()
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    vim.opt.sw = 2
    vim.opt.expandtab = true -- 在插入模式下，会把按 Tab 键所插入的 tab 字符替换为合适数目的空格。如果确实要插入 tab 字符，需要按 CTRL-V 键，再按 Tab 键
  end)

  M.register_fts_cb("qf", function()
    vim.cmd [[wincmd J]]
  end)

  local user_cmd = vim.api.nvim_create_user_command

  user_cmd("DiffOpen", helper.diff_open, {})
  user_cmd("BufOnly", helper.buf_only, {})

  local gotags = require "utils.gotags"
  user_cmd("GoAddTags", function(args)
    gotags.add(args["args"])
  end, { nargs = "+" })

  user_cmd("GoRemoveTags", function(args)
    gotags.remove(args["args"])
  end, { nargs = "+" })

  user_cmd("TestCmd", function() end, { range = true })
end

return M
