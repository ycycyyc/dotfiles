local plugin = {}

plugin.user_cmds = {
  {
    "SnacksShowHistory",
    ":lua Snacks.notifier.show_history()<cr>",
    {},
  },
}

plugin.initfuncs = {
  {
    "snacks_input",
    function()
      YcVim.keys.buf_map("i", "<C-w>", function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        local l = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        for i = 1, #l do
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<backspace>", true, false, true), "n", true)
        end
      end)
    end,
  },
}

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

plugin.config = function()
  local snacks = require "snacks"
  snacks.setup {
    dashboard = {
      preset = {
        pick = nil,
        keys = {
          { icon = "", key = "l", desc = " Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = "", key = "q", desc = " Quit", action = ":q" },
        },
      },
      formats = {
        icon = function(item)
          return { "", hl = "icon", width = 2 }
        end,
      },
      sections = {
        { section = "header" },
        { icon = "", section = "keys", indent = 2, padding = 1, gap = 1 },
        { icon = "", section = "recent_files", indent = 2, padding = 1, gap = 0.5 },
        { section = "startup" },
      },
    },
    input = {
      win = {
        relative = "cursor",
        row = -3,
        col = 0,
        keys = {
          i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i" },
        },
      },
      icon = ">",
    },
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

  YcVim.setup(plugin)

  vim.keymap.set("n", YcVim.keys.toggle_term, function()
    snacks.terminal.toggle(nil, {
      win = {
        on_buf = function(win)
          vim.keymap.set("t", YcVim.keys.toggle_term, function()
            snacks.terminal.toggle()
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

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  config = plugin.config,
}
