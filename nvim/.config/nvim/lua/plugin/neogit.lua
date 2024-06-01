local keys = require "basic.keys"
local helper = require "utils.helper"

local M = {
  keymaps = {
    {
      "n",
      keys.git_status,
      function()
        local neogit = require "neogit"
        neogit.open {}
      end,
      {},
    },
  },
}

M.init = function()
  vim.api.nvim_create_user_command("Gwrite", function()
    local Job = require "plenary.job"

    local args = {}

    local file = vim.fn.expand "%:p"

    table.insert(args, "add")
    table.insert(args, "--")
    table.insert(args, file)

    local errors = {}

    local job = Job:new {
      command = "git",
      args = args,
      on_stderr = function(_, data)
        table.insert(errors, data)
      end,
    }

    local output = job:sync()

    if job.code ~= 0 then
      vim.schedule(function()
        error(string.format("Gwrite run failed:%s", errors[1] or "Failed to format due to errors"))
      end)
    else
      vim.print("add file " .. vim.fn.expand "%:~:." .. " success")
    end
  end, {})
end

M.config = function()
  require("neogit").setup {
    auto_refresh = false,
    auto_close_console = false,
    remember_settings = false,
    disable_line_numbers = false,
    status = {
      recent_commit_count = 0, -- 去掉recent_commit
      mode_text = {
        M = "M",
        N = "N",
        D = "D",
        R = "R",
        A = "A",
      },
    },
    integrations = {
      fzf_lua = true,
    },
    mappings = {
      status = {},
    },
  }
  helper.setup_m(M)
end

return M
