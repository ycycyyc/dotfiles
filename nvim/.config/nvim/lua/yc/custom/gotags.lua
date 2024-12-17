local helper = require "utils.helper"

---@return string
---@return string
local function analyze()
  ---@type string
  local curline = vim.api.nvim_get_current_line()
  local struct_pos = string.find(curline, "struct")
  local type_pos = string.find(curline, "type")

  if struct_pos ~= nil and type_pos ~= nil then
    ---@type string[]
    local words = {}
    for w in string.gmatch(curline, "%S+") do
      table.insert(words, w)
    end
    return "-struct", words[2]
  else
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_num = cursor_pos[1]
    return "-line", tostring(line_num)
  end
end

---@param op string
---@param ty string
local function run(op, ty)
  local file = vim.api.nvim_buf_get_name(0)
  local type, range = analyze()

  local args = {}
  table.insert(args, "-file")
  table.insert(args, file)
  table.insert(args, type)
  table.insert(args, range)
  table.insert(args, op)
  table.insert(args, ty)

  local errors = {}
  local Job = require "plenary.job"
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
    return
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
end

---@param tags string
local function add(tags)
  run("-add-tags", tags)
end

---@param tags string
local function remove(tags)
  run("-remove-tags", tags)
end

local plugin = {}

  -- stylua: ignore
plugin.user_cmds = {
  { "GoAddTags", function(args) add(args["args"]) end, { nargs = "+" } },
  { "GoRemoveTags", function(args) remove(args["args"]) end, { nargs = "+" } },
}

YcVim.setup_m(plugin)
