---@param user_cmds table
local function setup_usercmd(user_cmds)
  for _, user_cmd in ipairs(user_cmds) do
    vim.api.nvim_create_user_command(user_cmd[1], user_cmd[2], user_cmd[3])
  end
end

---@param keymaps table
local function setup_keymaps(keymaps)
  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3], keymap[4])
  end
end

---@param initfuncs table
local function setup_initfuncs(initfuncs)
  for _, initfunc in ipairs(initfuncs) do
    require("utils.initfunc").add(initfunc[1], initfunc[2])
  end
end

---@param m table
YcVim.setup_plugin = function(m)
  if m.user_cmds then
    setup_usercmd(m.user_cmds)
  end

  if m.keymaps then
    setup_keymaps(m.keymaps)
  end

  if m.initfuncs then
    setup_initfuncs(m.initfuncs)
  end
end
