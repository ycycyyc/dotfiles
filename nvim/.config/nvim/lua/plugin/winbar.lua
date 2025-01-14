local colors = YcVim.colors
local bg = colors.cursor_grey4
local convert = colors.convert

local opts = {
  include_buftypes = { "", "nowrite", "nofile" },
  create_autocmd = false,
  modifiers = {
    dirname = ":~:.",
    basename = "",
  },

  theme = {
    normal = convert { mybg = bg },
    dirname = convert { bold = false, myfg = colors.white, mybg = bg },
    basename = convert { bold = true, myfg = colors.white, mybg = bg },
    modified = convert { bold = true, myfg = colors.red },
    context_method = convert { bold = false, myfg = colors.blue, mybg = bg },
    context_function = convert { bold = true, myfg = colors.blue, mybg = bg },
    context_field = convert { bold = false, myfg = colors.red, mybg = bg },

    context_struct = convert { bold = false, myfg = colors.yellow, mybg = bg },
    context_namespace = convert { bold = false, myfg = colors.red, mybg = bg },
    context_class = convert { bold = false, myfg = colors.yellow, mybg = bg },
    context_enum = convert { bold = false, myfg = colors.yellow, mybg = bg },
    context_constructor = convert { bold = false, myfg = colors.blue, mybg = bg },
    context_constant = convert { bold = false, myfg = colors.cyan, mybg = bg },
    context_variable = convert { bold = false, myfg = colors.white, mybg = bg },
    context_interface = convert { bold = false, myfg = colors.yellow, mybg = bg },
    context_object = convert { bold = false, myfg = colors.red, mybg = bg },
  },

  symbols = {
    modified = "[+]",
    ellipsis = "…",
    separator = "▸",
  },
  context_follow_icon_color = true,
  lead_custom_section = function()
    return { { " %{winnr()} ", "StatusLineWinnr" }, { " ", "StatusLineNormal" } }
  end,

  show_modified = true,
  show_dirname = true,
}

local config = function()
  vim.api.nvim_create_autocmd({
    YcVim.util.since_nvim(0, 9) and "WinResized" or "WinScrolled",
    "BufWinEnter",
    "CursorHold",
    "InsertLeave",

    -- include this if you have set `show_modified` to `true`
    "BufModifiedSet",
  }, {
    group = vim.api.nvim_create_augroup("barbecue.updater", {}),
    callback = function()
      require("barbecue.ui").update()
    end,
  })

  require("barbecue").setup(opts)
end

return {
  "utilyre/barbecue.nvim",
  event = "User FilePost",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    opts = {
      lazy_update_context = true,
    },
  },
  config = config,
  cond = YcVim.env.winbar,
}
