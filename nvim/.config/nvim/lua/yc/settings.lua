-- local keys = require "basic.keys"

local au_group = vim.api.nvim_create_augroup
local au_cmd = vim.api.nvim_create_autocmd

local M = {
  fts = {},
}

M.register_fts = function(fts, cb)
  if type(fts) == "string" then
    fts = { fts }
  end

  local rft = function(ft)
    if M.fts[ft] == nil then
      M.fts[ft] = {}
    end
    table.insert(M.fts[ft], cb)

    local filetype = vim.api.nvim_buf_get_option(0, "filetype")
    if filetype == ft then
      cb()
    end
  end

  for _, ft in ipairs(fts) do
    rft(ft)
  end

  -- refresh
  local file_grp = au_group("setting_ft", { clear = true })

  for ft, _ in pairs(M.fts) do
    au_cmd("FileType", {
      pattern = { ft },
      callback = function()
        local cbs = M.fts[ft]
        for _, cbi in ipairs(cbs) do
          cbi()
        end
      end,
      group = file_grp,
    })
  end
end

M.setup = function()
  -- Highlight on yank
  local yank_grp = au_group("YankHighlight", { clear = true })
  au_cmd("TextYankPost", {
    callback = function()
      vim.highlight.on_yank { timeout = 300 }
    end,
    group = yank_grp,
  })

  -- file type  group
  local helper = require "utils.helper"
  -- local bmap = helper.build_keymap { noremap = true, buffer = true }

  M.register_fts("lua", function()
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    vim.opt.sw = 2
    vim.opt.expandtab = true -- 在插入模式下，会把按 Tab 键所插入的 tab 字符替换为合适数目的空格。如果确实要插入 tab 字符，需要按 CTRL-V 键，再按 Tab 键
  end)

  M.register_fts("qf", function()
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
