local M = {}

M.keys = {
  { "ds", mode = "n" },
  { "cs", mode = "n" },
  { "ys", mode = "n" },
  { "S", mode = "x" },
}

M.opts = {
  keymaps = {
    -- disable this keymap
    normal_cur = false,
    normal_line = false,
    normal_cur_line = false,

    insert = false,
    insert_line = false,

    visual_line = false,
    change_line = false,
  },
}

return M
