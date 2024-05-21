local helper = require "utils.helper"
local buf_map = function(mode, key, action)
  vim.keymap.set(mode, key, action, { noremap = true, buffer = true, silent = true })
end

local M = {
  ---@type table<string, function[]>
  filetype_initfuncs = {},
  ---@type table[]
  user_cmds = {
    { "DiffOpen", helper.diff_open, {} },

    {
      "BufOnly",
      function()
        helper.buf_only()
        vim.api.nvim_exec_autocmds("User", {
          pattern = "LineRefresh",
        })
      end,
      {},
    },

    {
      "GoAddTags",
      function(args)
        local gotags = require "utils.gotags"
        gotags.add(args["args"])
      end,
      { nargs = "+" },
    },

    {
      "GoRemoveTags",
      function(args)
        local gotags = require "utils.gotags"
        gotags.remove(args["args"])
      end,
      { nargs = "+" },
    },
  },
}

M.refresh_initfunc = function()
  local group = vim.api.nvim_create_augroup("filetype_initfunc", { clear = true })
  for filetype, initfuncs in pairs(M.filetype_initfuncs) do
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { filetype },
      callback = function()
        for _, initfunc in ipairs(initfuncs) do
          initfunc()
        end
      end,
      group = group,
    })
  end
end

---@param filetypes string | string[]
---@param initfunc fun()
M.add_filetypes_initfunc = function(filetypes, initfunc)
  if type(filetypes) == "string" then
    filetypes = { filetypes }
  end

  ---@param ft string
  local add_initfunc = function(ft)
    if M.filetype_initfuncs[ft] == nil then
      M.filetype_initfuncs[ft] = {}
    end
    table.insert(M.filetype_initfuncs[ft], initfunc)

    -- 这里比较重要，直接打开文件的话， 可能第一个文件没有设置参数
    local current_filetype = vim.api.nvim_buf_get_option(0, "filetype")
    if current_filetype == ft then
      initfunc()
    end
  end

  for _, ft in ipairs(filetypes) do
    add_initfunc(ft)
  end

  M.refresh_initfunc()
end

M.highliht_yank = function()
  local group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      vim.highlight.on_yank { timeout = 300 }
    end,
    group = group,
  })
end

-- 关闭换行时， 自动注释
-- vim.cmd [[ autocmd FileType * set fo-=o ]]
M.setup = function()
  -- autocmd
  M.highliht_yank()

  M.add_filetypes_initfunc("qf", function()
    vim.cmd.wincmd "J"
    buf_map("n", "q", ":q<cr>")
  end)

  M.add_filetypes_initfunc("help", function()
    vim.cmd.wincmd "L"
  end)

  -- user_cmd
  for _, user_cmd in ipairs(M.user_cmds) do
    vim.api.nvim_create_user_command(user_cmd[1], user_cmd[2], user_cmd[3])
  end
end

return M
