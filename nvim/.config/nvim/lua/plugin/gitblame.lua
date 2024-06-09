local keys = require "basic.keys"
local helper = require "utils.helper"

local buf_map = function(mode, key, action)
  vim.keymap.set(mode, key, action, { noremap = true, buffer = true, silent = true })
end

-- blame.nvim 插件的功能
local native = function()
  local view = require("blame").last_opened_view
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local c = view.blamed_lines[row]

  if c.author == "Not Committed Yet" then
    require("utils.git").commit_diff()
    return
  end
  require("utils.git").commit_diff(c.hash)
end

local diffCommit = function()
  buf_map("n", "<cr>", function()
    local current_line = vim.api.nvim_get_current_line()
    local items = vim.fn.split(current_line) ---@type string[]

    if items[1] == "Not" then
      require("utils.git").commit_diff()
      return
    end
    require("utils.git").commit_diff(items[1])
  end)
end

local M = {
  keymaps = {
    {
      "n",
      keys.git_blame,
      ":BlameToggle<cr>",
      {},
    },
  },
  initfuncs = {
    { "blame", diffCommit },
  },
}

M.config = function()
  require("blame").setup {
    date_format = "%Y.%m.%d",
    mappings = {
      commit_info = "i",
      stack_push = "<TAB>",
      stack_pop = "<BS>",
      show_commit = "<c-+>g",
      close = { "<esc>", "q" },
    },
  }
  helper.setup_m(M)

  --  you can do something like this: there are some conflicts with some winbar plugins,
  --  in this case barbecue is toggled
  vim.api.nvim_create_autocmd("User", {
    pattern = "BlameViewOpened",
    callback = function(event)
      local blame_type = event.data
      if blame_type == "window" then
        require("barbecue.ui").toggle(false)
      end
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "BlameViewClosed",
    callback = function(event)
      local blame_type = event.data
      if blame_type == "window" then
        require("barbecue.ui").toggle(true)
      end
    end,
  })
end

return M
