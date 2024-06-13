local keys = require "basic.keys"
local helper = require "utils.helper"

local terminals = {}

---Open a floating terminal (interactive by default)
---@param cmd string?
---@param opts table?
---@return function
local function open_term(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    ft = "terminal",
    size = { width = 0.9, height = 0.8 },
    backdrop = 100,
  }, opts or {}, { persistent = true, border = "rounded" })

  local termkey = vim.inspect { cmd = cmd or "shell", cwd = opts.cwd, env = opts.env }

  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("User", { pattern = "LineRefresh" })
  end, 0)

  if terminals[termkey] and terminals[termkey]:buf_valid() then
    terminals[termkey]:toggle()
  else
    terminals[termkey] = require("lazy.util").float_term(cmd, opts)
    local buf = terminals[termkey].buf
    vim.b[buf].lazyterm_cmd = cmd

    vim.keymap.set("t", keys.toggle_term, function()
      terminals[termkey]:toggle()
    end, { buffer = buf, nowait = true })

    vim.keymap.set("n", "gf", function()
      local f = vim.fn.findfile(vim.fn.expand "<cfile>")
      if f ~= "" then
        vim.cmd "close"
        vim.cmd("e " .. f)
      end
    end, { buffer = buf })

    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = buf,
      callback = function()
        vim.cmd.startinsert()
      end,
    })
  end

  return terminals[termkey]
end

local M = {
  keymaps = {
    {
      "n",
      keys.toggle_term,
      function()
        open_term(nil, nil)
      end,
      {},
    },
  },
}

function M.setup()
  helper.setup_m(M)
end

return M
