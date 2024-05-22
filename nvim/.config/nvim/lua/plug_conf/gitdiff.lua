local keys = require "basic.keys"
local helper = require "utils.helper"

local buf_map = function(mode, key, action)
  vim.keymap.set(mode, key, action, { noremap = true, buffer = true, silent = true })
end

local M = {
  keymaps = {
    {
      "n",
      keys.git_diff_file,
      function()
        local file = vim.fn.expand "%:~:."
        vim.cmd("DiffviewFileHistory " .. file)
      end,
      {},
    },
  },
  initfuncs = {
    {
      { "DiffviewFiles", "DiffviewFileHistory" },
      function()
        local close = function()
          vim.cmd "DiffviewClose"
          vim.cmd "silent! checktime"
        end

        buf_map("n", "<leader>q", close)
        buf_map("n", "q", close)
        buf_map("n", "<esc>", close)
      end,
    },
  },
}

M.config = function()
  local opt = require "plug_conf.gitdiff_opt"
  require("diffview").setup(opt)

  helper.setup_m(M)
end

---@param commit string
M.show_diff = function(commit)
  local idx = vim.fn.stridx(commit, "^") ---@type number
  local cmd = "" ---@type string

  if idx >= 0 then
    vim.notify "it's first commit"
    cmd = "DiffviewOpen " .. commit
  else
    cmd = "DiffviewOpen " .. commit .. "^!"
  end

  vim.notify("Run cmd: " .. cmd)
  vim.cmd(cmd)
end

return M
