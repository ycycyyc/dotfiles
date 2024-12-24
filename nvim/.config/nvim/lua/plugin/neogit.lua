local plugin = {}

plugin.toggle_git_status = function()
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

plugin.init = function()
  local stage_file = function()
    local file = vim.fn.expand "%:p"

    local git = require "neogit.lib.git"
    git.status.stage { file }

    vim.notify("stage file:" .. file)
  end

  vim.api.nvim_create_user_command("Gwrite", stage_file, {})
  vim.api.nvim_create_user_command("Gw", stage_file, {})
end

return {
  "NeogitOrg/neogit",
  init = plugin.init,
  cmd = { "Neogit" },
  keys = {
    { YcVim.keys.git_status, plugin.toggle_git_status },
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
    notification_icon = "",
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
    disable_insert_on_commit = true,
  },
}
