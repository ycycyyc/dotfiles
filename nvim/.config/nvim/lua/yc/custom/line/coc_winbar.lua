local util = YcVim.util

local M = {}

M.update_all = function()
  for _, winnr in ipairs(vim.api.nvim_list_wins()) do
    M.update(winnr)
  end
end

local ignore_filename = {}
local ignore_ft = {}

---@return string
M.func = function()
  local func = vim.b.coc_current_function
  if func then
    func = util.add_theme("StatusLineFunction", " " .. func, "StatusLineNormal")
  else
    return ""
  end
  return func
end

---@return string
M.diagnostic_info = function()
  local diag = vim.b.coc_diagnostic_info
  if not diag then
    return ""
  end

  local msgs = ""

  if diag.error and diag.error > 0 then
    msgs = msgs .. util.add_theme("StatusLineError", " E: " .. diag.error, "StatusLineNormal")
  end

  if diag.warning and diag.warning > 0 then
    msgs = msgs .. util.add_theme("StatusLineWarnning", " W: " .. diag.warning, "StatusLineNormal")
  end

  return msgs
end

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

    local str = ""

    local filename = vim.fn.expand "%:t"
    if ignore_filename[filename] then
      return
    end
    filename = util.add_theme("StatusLineCurFile", filename, "StatusLineNormal")

    str = filename .. M.diagnostic_info() .. M.func()

    local winnr_str = util.add_theme("StatusLineWinnr", "%{winnr()} ", "StatusLineNormal")

    vim.wo[winnr].winbar = winnr_str .. str
  end, 100)
end

M.start = function()
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
  ignore_ft["fugitive"] = 1
  ignore_ft["lazy"] = 1
  ignore_ft["TelescopePrompt"] = 1
  ignore_ft["DiffviewFilePanel"] = 1
  ignore_ft["DiffviewFiles"] = 1
  ignore_ft["checkhealth"] = 1
  ignore_ft["coc-explorer"] = 1
  ignore_ft[""] = 1
end

return M
