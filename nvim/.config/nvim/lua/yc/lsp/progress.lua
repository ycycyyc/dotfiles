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
  if vim.fn.has "nvim-0.10" == 1 then
    vim.api.nvim_create_autocmd({ "LspProgress" }, {
      callback = function(status)
        if status and status.data and status.data.result and status.data.result.value then
          local client_id = status.data.client_id
          local name = ""
          if client_id then
            name = vim.lsp.get_client_by_id(client_id).name or ""
          end

          local res = status.data.result
          local kind = res.value.kind or "end"
          local msg = res.value.message or ""
          local title = res.value.title or ""
          local percentage = res.value.percentage or 0

          if kind == "end" then
            vim.defer_fn(function()
              show:show ""
            end, 1000)
          else
            local info = string.format("%s: %s %s (%s%%) ", name, title, msg, percentage)
            show:show(info)
          end
        else
          vim.defer_fn(function()
            show:show ""
          end, 1000)
        end
      end,
    })
  else
    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = "LspProgressUpdate",
      callback = M.update,
    })
  end
end

return M
