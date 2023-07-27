local M = {}

M.opts = {
  line_sep_start = "┌-----------------------------------------",
  result_padding = "¦  ",
  line_sep = "└-----------------------------------------",
  highlight = {
    ui = "String",
    search = "DiffChange",
    replace = "DiffDelete",
  },
  mapping = {
    ["send_to_qf"] = {
      map = "<leader>x",
      cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
      desc = "send all item to quickfix",
    },
  },
  find_engine = {
    -- rg is map with finder_cmd
    ["rg"] = {
      cmd = "rg",
      -- default args
      args = {
        "--color=never",
        "--no-heading",
        "--glob=!.git/", -- ignore .git/
        "--with-filename",
        "--line-number",
        "--column",
      },
      options = {
        ["ignore-case"] = {
          value = "--ignore-case",
          icon = "[I]",
          desc = "ignore case",
        },
        ["hidden"] = {
          value = "--hidden",
          desc = "hidden file",
          icon = "[H]",
        },
        -- you can put any rg search option you want here it can toggle with
        -- show_option function
      },
    },
  },
}

return M
