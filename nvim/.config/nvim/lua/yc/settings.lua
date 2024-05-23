local helper = require "utils.helper"

local buf_map = function(mode, key, action)
  vim.keymap.set(mode, key, action, { noremap = true, buffer = true, silent = true })
end

local M = {
  initfuncs = {
    {
      "qf",
      function()
        vim.cmd.wincmd "J"
        buf_map("n", "q", ":q<cr>")
      end,
    },
    {
      "help",
      function()
        vim.cmd.wincmd "L"
      end,
    },
  },

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

M.autocmds = function()
  -- "gbprod/yanky.nvim" 使用这个插件代替先
  -- local group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
  -- vim.api.nvim_create_autocmd("TextYankPost", {
  --   callback = function()
  --     vim.highlight.on_yank { timeout = 300 }
  --   end,
  --   group = group,
  -- })
end

-- 关闭换行时， 自动注释
-- vim.cmd [[ autocmd FileType * set fo-=o ]]
M.setup = function()
  M.autocmds()
  helper.setup_m(M)
end

return M
