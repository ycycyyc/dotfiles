local keys = require "basic.keys"
local helper = require "utils.helper"

-- copy from neogit/buffers/status/actions.lua
local function open(type, path, cursor)
  vim.cmd(("silent! %s %s | %s | norm! zz"):format(type, vim.fn.fnameescape(path), cursor and cursor[1] or "1"))
end

local jumpto_window = function()
  local ignore_types = { "NeogitStatus", "lsp_progresss", "qf", "NvimTree" }
  local wins = vim.api.nvim_list_wins()
  for _, win_num in ipairs(wins) do
    local buf_num = vim.fn.winbufnr(win_num)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf_num })
    if not vim.tbl_contains(ignore_types, ft) then
      vim.api.nvim_set_current_win(win_num)
      vim.cmd "redraw"
      return
    end
  end
end

-- copy from neogit/buffers/status/actions.lua
local function translate_cursor_location(self, item)
  if rawget(item, "diff") then
    local line = self.buffer:cursor_line()

    for _, hunk in ipairs(item.diff.hunks) do
      if line >= hunk.first and line <= hunk.last then
        local offset = line - hunk.first
        local row = hunk.disk_from + offset - 1

        for i = 1, offset do
          -- If the line is a deletion, we need to adjust the row
          if string.sub(hunk.lines[i], 1, 1) == "-" then
            row = row - 1
          end
        end

        return { row, 0 }
      end
    end
  end
end

local M = {
  keymaps = {
    {
      "n",
      keys.git_status,
      function()
        local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
        if ft == "NeogitStatus" then
          vim.api.nvim_input "q"
          return
        end

        local neogit = require "neogit"
        neogit.open { kind = "vsplit_left" }
        vim.cmd "vertical res 80"
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
    filewatcher = {
      enabled = false,
    },
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

  local action = require "neogit.buffers.status.actions"

  action.n_goto_file = function(self)
    return function()
      local item = self.buffer.ui:get_item_under_cursor()

      if item and item.absolute_path then
        local cursor = translate_cursor_location(self, item)
        -- self:close()
        jumpto_window()
        open("edit", item.absolute_path, cursor)
        return
      end
    end
  end

  helper.setup_m(M)
end

return M
