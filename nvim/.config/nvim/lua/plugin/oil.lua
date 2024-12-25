local plugin = {}

plugin.initfuncs = {
  {
    "oil",
    function()
      vim.b.completion = false
      YcVim.keys.buf_map("n", "q", function()
        require("oil").close()
      end)
    end,
  },
}

local type_hlgroups = setmetatable({
  ["▸"] = "Directory",
}, {
  __index = function()
    return "OilTypeFile"
  end,
})

return {
  "stevearc/oil.nvim",
  init = function()
    YcVim.setup(plugin)
  end,
  keys = {
    {
      YcVim.keys.toggle_dir,
      function()
        require("oil").toggle_float()
      end,
    },
    {
      YcVim.keys.toggle_dir_open_file,
      function()
        require("oil").toggle_float "."
      end,
    },
  },
  opts = {
    columns = {
      {
        "type",
        icons = {
          directory = "▸",
          file = "",
        },
        highlight = function(type_str)
          return type_hlgroups[type_str]
        end,
      },
    },
    default_file_explorer = false,
    keymaps = {
      ["<CR>"] = "actions.select",
      ["<c-l>"] = "actions.select",
      ["<c-h>"] = "actions.parent",
      ["<c-r>"] = "actions.open_cwd",
      ["<C-p>"] = "actions.preview",
      ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
    },
    use_default_keymaps = false,
    win_options = {
      winhighlight = "Normal:MyFloatNormal",
    },
    float = {
      padding = 4,
      max_width = 200,
    },
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, _)
        return name == ".." or name == ".git"
      end,
    },
  },
}
