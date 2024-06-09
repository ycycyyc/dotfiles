local keys = require "basic.keys"
local helper = require "utils.helper"

-- copy from neogit/buffers/status/actions.lua
local function open(type, path, cursor)
  vim.cmd(("silent! %s %s | %s | norm! zz"):format(type, vim.fn.fnameescape(path), cursor and cursor[1] or "1"))
end

local hide_window = function(win, hide)
  local config = vim.api.nvim_win_get_config(win)
  local new_config = vim.tbl_deep_extend("force", config, { hide = hide })
  vim.api.nvim_win_set_config(win, new_config)
end

local jumpto_window = function(path)
  local ignore_types = { "NeogitStatus", "lsp_progresss", "qf", "NvimTree" }
  local wins = vim.api.nvim_list_wins()

  local s_wins = {}

  for _, win_num in ipairs(wins) do
    local buf_num = vim.fn.winbufnr(win_num)

    -- 1. win中文件已经打开
    if vim.api.nvim_buf_get_name(buf_num) == path then
      vim.api.nvim_set_current_win(win_num)
      vim.cmd "redraw"
      return
    end

    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf_num })

    if not vim.tbl_contains(ignore_types, ft) then
      table.insert(s_wins, win_num)
    end
  end

  -- 2. 当前没有可用的window
  if #s_wins == 0 then
    open("edit", path)
    return
  end

  -- 3. 选择第一个window
  vim.api.nvim_set_current_win(s_wins[1])
  vim.cmd("edit " .. path)
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
        vim.defer_fn(function()
          vim.cmd "checktime"
        end, 200)

        local cur_win = vim.api.nvim_get_current_win()
        local wins = helper.get_winnums_byft "NeogitStatus"

        for _, winn in ipairs(wins) do
          -- 1. 当前正处于Neogit中, 退出
          if cur_win == winn then
            vim.api.nvim_input "q"
            return
          end
        end

        -- 2. 没有打开Neogit
        if #wins == 0 then
          local neogit = require "neogit"
          neogit.open { kind = "floating" }
          return
        elseif #wins > 1 then -- 非预期行为不能同时存在多个NeogitStatus window
          vim.notify("got " .. tostring(#wins) .. " not expected")
          return
        end

        -- 3. 打开了neogit, 但是处于其他buf中
        vim.api.nvim_set_current_win(wins[1])
        hide_window(wins[1], false)
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
      vim.notify("add file " .. vim.fn.expand "%:~:." .. " success")
    end
  end, {})
end

M.config = function()
  require("neogit").setup {
    kind = "floating",
    commit_editor = {
      kind = "tab",
    },
    commit_select_view = {
      kind = "tab",
    },
    commit_view = {
      kind = "tab",
      verify_commit = vim.fn.executable "gpg" == 1,
    },
    log_view = {
      kind = "tab",
    },
    rebase_editor = {
      kind = "tab",
    },
    reflog_view = {
      kind = "tab",
    },
    merge_editor = {
      kind = "tab",
    },
    description_editor = {
      kind = "tab",
    },
    tag_editor = {
      kind = "tab",
    },
    preview_buffer = {
      kind = "tab",
    },
    popup = {
      kind = "floating",
    },
    refs_view = {
      kind = "tab",
    },

    filewatcher = {
      enabled = false,
    },
    auto_refresh = false,
    auto_close_console = false,
    remember_settings = false,
    disable_line_numbers = false,
    status = {
      -- recent_commit_count = 30, -- 去掉recent_commit
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
    disable_insert_on_commit = true,
  }

  local action = require "neogit.buffers.status.actions"

  action.n_goto_file = function(self)
    return function()
      local item = self.buffer.ui:get_item_under_cursor()

      if item and item.absolute_path then
        hide_window(vim.api.nvim_get_current_win(), true)

        jumpto_window(item.absolute_path)
        return
      end
    end
  end

  helper.setup_m(M)
end

return M
