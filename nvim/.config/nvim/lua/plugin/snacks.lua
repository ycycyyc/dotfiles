local keys = require "basic.keys"

local M = {}

--- https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md
vim.api.nvim_create_autocmd("LspProgress", {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    vim.notify(vim.lsp.status(), "info", {
      id = "lsp_progress",
      title = "LSP Progress",
      opts = function(notif)
        notif.icon = ev.data.params.value.kind == "end" and " "
          or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})

M.config = function()
  local sn = require "snacks"
  sn.setup {
    notifier = {
      enabled = true,
      icons = {
        error = "E ",
        warn = "W ",
        info = "I ",
        debug = "E ",
        trace = "T ",
      },
      margin = { top = 1, right = 1, bottom = 1 },
    },
  }

  vim.keymap.set("n", keys.toggle_term, function()
    sn.terminal.toggle(nil, {
      win = {
        on_buf = function(win)
          vim.keymap.set("t", keys.toggle_term, function()
            sn.terminal.toggle()
          end, { buffer = win.buf, nowait = true })
        end,
        border = "rounded",
        position = "float",
        backdrop = 100,
        width = 0.85,
        height = 0.8,
        wo = { winhighlight = "Normal:Normal" },
      },
    })

    vim.defer_fn(function()
      vim.api.nvim_exec_autocmds("User", { pattern = "LineRefresh" })
    end, 0)
  end)
end

return M
