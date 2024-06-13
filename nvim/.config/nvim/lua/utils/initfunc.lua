local group = vim.api.nvim_create_augroup("lang_initfunc", { clear = true })

---@param lang string
---@param initfunc function
local add = function(lang, initfunc)
  local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  if ft == lang then
    initfunc()
  end

  vim.api.nvim_create_autocmd("FileType", { group = group, pattern = { lang }, callback = initfunc })
end

local M = {}

---@param langs string | string[]
---@param initfunc function
M.add = function(langs, initfunc)
  if type(langs) == "string" then
    langs = { langs }
  end

  for _, lang in ipairs(langs) do
    add(lang, initfunc)
  end
end

return M
