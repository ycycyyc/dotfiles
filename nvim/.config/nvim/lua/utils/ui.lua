local M = {}

---@param cb function
M.select = function(cb)
  local ui_select = require "fzf-lua.providers.ui_select"

  if ui_select.is_registered() then
    vim.notify "use native vim.ui.select"
    cb()
    return
  end

  ui_select.register()
  cb()

  ui_select.deregister()
  if ui_select.is_registered() then
    vim.notify "deregister fzf-lua ui_select failed"
  end
end

return M
