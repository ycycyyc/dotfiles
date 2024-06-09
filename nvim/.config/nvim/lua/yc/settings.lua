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

    {
      "CpFilePath",
      function()
        local path = vim.fn.expand "%:~:."
        vim.notify("copy path: " .. path, vim.log.levels.INFO)
        vim.fn.setreg("0", path)
        vim.fn.setreg('"', path)
      end,
      {},
    },
  },
}

M.autocmds = function()
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    callback = function()
      vim.highlight.on_yank { timeout = 300 }
    end,
  })

  -- https://github.com/NvChad/NvChad/blob/v2.0/lua/core/init.lua#L111
  -- user event that loads after UIEnter + only if file buf is there
  vim.api.nvim_create_autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("NvFilePost", { clear = true }),
    callback = function(args)
      local file = vim.api.nvim_buf_get_name(args.buf)
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

      if not vim.g.ui_entered and args.event == "UIEnter" then
        vim.g.ui_entered = true
      end

      if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
        vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
        vim.api.nvim_del_augroup_by_name "NvFilePost"

        vim.schedule(function()
          vim.api.nvim_exec_autocmds("FileType", {})

          if vim.g.editorconfig then
            require("editorconfig").config(args.buf)
          end
        end)
      end
    end,
  })
end

-- 关闭换行时， 自动注释
-- vim.cmd [[ autocmd FileType * set fo-=o ]]
M.setup = function()
  M.autocmds()
  helper.setup_m(M)
end

return M
