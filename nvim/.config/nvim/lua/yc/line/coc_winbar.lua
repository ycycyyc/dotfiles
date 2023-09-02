local utils = require "yc.line.utils"

local M = {}

M.update_all = function()
  for _, winnr in ipairs(vim.api.nvim_list_wins()) do
    M.update(winnr)
  end
end

local ignore_filename = {}
local ignore_ft = {}

---@param winnr? number
M.update = function(winnr)
  winnr = winnr or vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winnr)

  -- 延迟更新，避免coc_current_function还没来得及更新
  vim.defer_fn(function()
    if
      not vim.api.nvim_buf_is_valid(bufnr)
      or not vim.api.nvim_win_is_valid(winnr)
      or bufnr ~= vim.api.nvim_win_get_buf(winnr)
    then
      return
    end

    local ft = vim.bo[bufnr].filetype
    if ignore_ft[ft] then
      return
    end

    local filename = vim.fn.expand "%:t"
    if ignore_filename[filename] then
      return
    end

    filename = utils.add_theme("StatusLineCurFile", filename, "StatusLineNormal")

    local func = vim.b.coc_current_function
    if func then
      func = utils.add_theme("StatusLineFunction", func, "StatusLineNormal")
      vim.wo[winnr].winbar = filename .. " " .. func
    else
      vim.wo[winnr].winbar = filename
    end
  end, 100)
end

M.init = function()
  vim.api.nvim_create_autocmd({ "CursorHold", "BufEnter" }, {
    callback = function()
      M.update()
    end,
  })

  ignore_filename["[coc-explorer]-1"] = 1
  ignore_filename["CocTree1"] = 1
  ignore_filename["zsh;#toggleterm#1"] = 1

  ignore_ft["qf"] = 1
  ignore_ft["fzf"] = 1
  ignore_ft[""] = 1
end

return M
