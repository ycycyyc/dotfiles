local show = require "yc.lsp.show"

local M = {}

---@return string
function M:lsp_progress()
  local lsp = vim.lsp.util.get_progress_messages()[1]
  if lsp then
    local name = lsp.name or ""
    local msg = lsp.message or ""
    local percentage = lsp.percentage or 0
    local title = lsp.title or ""
    local done = lsp.done or false

    if done then
      vim.defer_fn(M.update, 1000)
    end

    return string.format(" %s: %s %s (%s%%) ", name, title, msg, percentage)
  end

  return ""
end

M.update = function()
  local content = M:lsp_progress()
  show:show(content)
end

M.setup = function()
  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "LspProgressUpdate",
    callback = M.update,
  })
end

return M
