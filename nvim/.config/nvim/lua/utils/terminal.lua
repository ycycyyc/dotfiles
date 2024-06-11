local keys = require "basic.keys"

local M = {}

local terminals = {}

---Open a floating terminal (interactive by default)
---@param cmd string?
---@param opts table?
---@return function
function M.open_term(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    ft = "terminal",
    size = { width = 0.9, height = 0.8 },
    backdrop = 100,
  }, opts or {}, { persistent = true, border = "rounded" })

  local termkey = vim.inspect { cmd = cmd or "shell", cwd = opts.cwd, env = opts.env }

  if terminals[termkey] and terminals[termkey]:buf_valid() then
    terminals[termkey]:toggle()
  else
    terminals[termkey] = require("lazy.util").float_term(cmd, opts)
    local buf = terminals[termkey].buf
    vim.b[buf].lazyterm_cmd = cmd

    vim.keymap.set("t", keys.toggle_term, function()
      terminals[termkey]:toggle()
    end, { buffer = buf, nowait = true })

    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = buf,
      callback = function()
        vim.cmd.startinsert()
      end,
    })
  end

  return terminals[termkey]
end

return M
