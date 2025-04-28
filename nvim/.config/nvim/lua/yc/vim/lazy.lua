---@class YcVim.lazy
local lazy = {}

---@param keymaps table[]
---@param extra string[]?
---@return string[]
lazy.keys = function(keymaps, extra)
  local keys = extra or {}

  if not keymaps then
    return keys
  end

  local add = function(keymap)
    if not keymap then
      return
    end

    if keymap[#keymap].lazy_load_ignore then
      return
    end

    table.insert(keys, {
      keymap[2],
      mode = keymap[1],
    })
  end

  for _, keymap in ipairs(keymaps) do
    add(keymap)
  end

  return keys
end

---@param user_cmds table[]
---@param extra string[]?
---@return string[]
lazy.cmds = function(user_cmds, extra)
  local cmds = extra or {}

  if not user_cmds then
    return cmds
  end

  for _, user_cmd in ipairs(user_cmds) do
    table.insert(cmds, user_cmd[1])
  end

  return cmds
end

return lazy
