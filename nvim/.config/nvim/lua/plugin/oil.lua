---@type YcVim.Setup
local setup = {}

setup.initfuncs = {
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

YcVim.setup(setup)

return {
  "stevearc/oil.nvim",
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
