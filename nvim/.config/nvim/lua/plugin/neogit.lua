local toggle_neogit = function()
  vim.defer_fn(function()
    vim.cmd "checktime"
  end, 200)

  local cur_win = vim.api.nvim_get_current_win()

  local wins = YcVim.util.get_winnums_like_ft "Neogit"
  for _, winn in ipairs(wins) do
    if cur_win == winn then
      vim.api.nvim_input "q"
      return
    end
  end

  require("neogit").open {}
end

local stage_file = function()
  local file = vim.fn.expand "%:p"

  local git = require "neogit.lib.git"
  git.status.stage { file }

  vim.notify("stage file:" .. vim.fn.expand "%:~:.")
end

local init = function()
  vim.api.nvim_create_user_command("Gwrite", stage_file, {})
  vim.api.nvim_create_user_command("Gw", stage_file, {})

  vim.api.nvim_create_autocmd("User", {
    pattern = "NeogitReset",
    callback = function()
      vim.defer_fn(function()
        vim.cmd "checktime"
      end, 200)

      local wins = YcVim.util.get_winnums_byft "NeogitLogView"
      for _, win in ipairs(wins) do
        vim.api.nvim_buf_delete(vim.fn.winbufnr(win), { force = false })
        vim.notify("delete NeogitLogView win:" .. win)
      end

      local status_buffer = require "neogit.buffers.status"
      if status_buffer.is_open() then
        status_buffer.instance():dispatch_refresh(nil, "reset_complete")
      end
    end,
  })
end

return {
  "NeogitOrg/neogit",
  init = init,
  cmd = { "Neogit" },
  keys = {
    { YcVim.keys.git_status, toggle_neogit },
  },
  opts = {
    kind = "floating",
    log_view = {
      kind = "auto",
    },
    commit_editor = {
      kind = "auto",
    },
    filewatcher = { enabled = false },
    auto_refresh = false,
    auto_close_console = false,
    remember_settings = false,
    disable_line_numbers = false,
    disable_insert_on_commit = true,
  },
}
