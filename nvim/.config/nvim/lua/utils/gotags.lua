local M = {}

local api = vim.api
local Job = require "plenary.job"

---@return string
---@return string
local function get_ty_and_range()
  ---@type string
  local cur_line_content = api.nvim_get_current_line()
  local struct_word_pos = string.find(cur_line_content, "struct")
  local type_word_pos = string.find(cur_line_content, "type")

  if struct_word_pos ~= nil and type_word_pos ~= nil then
    ---@type string[]
    local words = {}
    for w in string.gmatch(cur_line_content, "%S+") do
      table.insert(words, w)
    end
    return "-struct", words[2]
  else
    local cursor_pos = api.nvim_win_get_cursor(0)
    local line_num = cursor_pos[1]
    return "-line", tostring(line_num)
  end
  error "get tag range failed"
end

---@param tags_op string
---@param tags_type string
local function op_go_tags(tags_op, tags_type)
  local file_name = api.nvim_buf_get_name(0)
  local type, range = get_ty_and_range()

  local args = {}
  table.insert(args, "-file")
  table.insert(args, file_name)
  table.insert(args, type)
  table.insert(args, range)
  table.insert(args, tags_op)
  table.insert(args, tags_type)

  local errors = {}
  local job = Job:new {
    command = "gomodifytags",
    args = args,
    on_stderr = function(_, data)
      table.insert(errors, data)
    end,
  }

  local output = job:sync()
  if job.code ~= 0 then
    vim.schedule(function()
      error(string.format("[gomodifytags] %s", errors[1] or "Failed to format due to errors"))
    end)
  end

  api.nvim_buf_set_lines(0, 0, -1, false, output)
end

---@param tags string
function M.add(tags)
  op_go_tags("-add-tags", tags)
end

---@param tags string
function M.remove(tags)
  op_go_tags("-remove-tags", tags)
end

function M.bin_exist(cmd, args)
  local job = Job:new {
    command = cmd,
    args = args,
  }
  job:sync()
  return job.code == 0
end

return M
