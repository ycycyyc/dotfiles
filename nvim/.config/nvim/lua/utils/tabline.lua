local M = {}

local api = vim.api
local fn = vim.fn
local user_cmd = vim.api.nvim_create_user_command

local function tabline()
  local s = " "
  -- local m_bufnr = vim.fn.bufnr "$"

  local cur_bufnr = api.nvim_get_current_buf()
  local list = api.nvim_list_bufs()
  for _, index in pairs(list) do
    -- if index > m_bufnr then
    --   break
    -- end

    if fn.buflisted(index) == 1 then
      local ft = fn.getbufvar(index, "&filetype")
      if ft ~= "fugitive" and ft ~= "qf" then
        s = s .. "%" .. index .. "T"
        if index == cur_bufnr then
          s = s .. "%#TabLineSel#"
        else
          s = s .. "%#TabLine#"
        end
        local bufname = fn.bufname(index)
        s = s .. " " .. index .. ":"
        if bufname ~= "" then
          s = s .. fn.fnamemodify(bufname, ":t") .. " "
        else
          s = s .. "[no name]" .. " "
        end
      end
    end
  end

  s = s .. "%#TabLineFill#"
  return s
end

function M.setup()
  user_cmd("TestBuf", tabline, {})

  function _G.nvim_tabline()
    return tabline()
  end

  vim.o.showtabline = 2
  vim.o.tabline = "%!v:lua.nvim_tabline()"

  vim.g.loaded_nvim_tabline = 1
end

return M
