---@type table<string, function[]>
local filetype_initfuncs = {}

local M = {}

local refresh_initfunc = function()
  local group = vim.api.nvim_create_augroup("filetype_initfunc", { clear = true })
  for filetype, initfuncs in pairs(filetype_initfuncs) do
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { filetype },
      callback = function()
        for _, initfunc in ipairs(initfuncs) do
          initfunc()
        end
      end,
      group = group,
    })
  end
end

---@param filetypes string | string[]
---@param initfunc fun()
M.add_filetypes_initfunc = function(filetypes, initfunc)
  if type(filetypes) == "string" then
    filetypes = { filetypes }
  end

  ---@param ft string
  local add_initfunc = function(ft)
    if filetype_initfuncs[ft] == nil then
      filetype_initfuncs[ft] = {}
    end
    table.insert(filetype_initfuncs[ft], initfunc)

    -- 这里比较重要，直接打开文件的话， 可能第一个文件没有设置参数
    local current_filetype = vim.api.nvim_buf_get_option(0, "filetype")
    if current_filetype == ft then
      initfunc()
    end
  end

  for _, ft in ipairs(filetypes) do
    add_initfunc(ft)
  end

  refresh_initfunc()
end

return M
