local keys = require "basic.keys"
local helper = require "utils.helper"

local openNeogit = function()
  local neogit = require "neogit"
  neogit.open { kind = "vsplit_left" }

  vim.cmd("vertical res " .. tostring(80))
end

local function toggleGit()
  local winns = helper.get_winnums_byft "NeogitStatus"
  local cur_win = vim.api.nvim_get_current_win()

  for _, winn in ipairs(winns) do
    --  当前所在的win刚好是futitive， 那么就close fugitive
    if cur_win == winn then
      vim.api.nvim_buf_delete(vim.fn.winbufnr(cur_win), { force = false })
      return
    end
  end

  if #winns == 0 then
    openNeogit()
  else -- 直接跳转过去， 避免从头开始
    require("utils.helper").try_jumpto_ft_win "NeogitStatus"
  end
end

local M = {
  keymaps = {
    {
      "n",
      keys.git_status,
      function()
        local neogit = require "neogit"
        neogit.open { kind = "replace" }
      end,
      {},
    },
  },
}

M.config = function()
  require("neogit").setup {
    auto_refresh = false,
    auto_close_console = false,
    status = {
      mode_text = {
        M = "M",
        N = "n",
      },
    },
    integrations = {
      fzf_lua = true,
    },
    mappings = {
      status = {
        -- ["<enter>"] = "VSplitOpen",
      },
    },
  }
  helper.setup_m(M)
end

return M
