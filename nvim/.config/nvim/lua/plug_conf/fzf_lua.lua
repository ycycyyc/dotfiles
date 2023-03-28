local M = {}

local helper = require "utils.helper"
local map = helper.build_keymap { noremap = true }
local bmap = helper.build_keymap { noremap = true, buffer = true }
local au_cmd = vim.api.nvim_create_autocmd
local au_group = vim.api.nvim_create_augroup

M.config = function()
  local keys = require "basic.keys"

  -- " 让输入上方，搜索列表在下方
  vim.env.FZF_DEFAULT_OPTS = "--layout=reverse"
  vim.g.fzf_preview_window = { "up:40%", "ctrl-/" }

  require("fzf-lua").setup {
    winopts = {
      width = 0.90, -- window width
      height = 0.95, -- window height
      fullscreen = false,
      preview = {
        -- layout = "reverse",
        layout = "up:+{2}-/2",
        vertical = "up:45%",
      },
    },
  }

  map("n", keys.search_find_files, ":FzfLua files<cr>")
  map("n", keys.search_buffer, ":FzfLua grep_curbuf<cr>")
  map("n", keys.search_global, ":FzfLua grep<cr>")
  map("n", keys.search_git_grep, function()
    -- require("fzf-lua").grep { cmd = "git grep -i --untracked --line-number --column --color=always" }
    require("fzf-lua").grep { cmd = "rg --hidden --column --line-number --no-heading --color=always --smart-case -- " }
  end)

  local file_grp = au_group("fzf_lua_filetype", { clear = true })

  au_cmd("FileType", {
    pattern = { "go" },
    callback = function()
      bmap("n", keys.search_global, function()
        require("fzf-lua").grep { cmd = "rg --column --line-number --no-heading -t go --color=always --smart-case -- " }
      end)
    end,
    group = file_grp,
  })

  au_cmd("FileType", {
    pattern = { "c" },
    callback = function()
      bmap("n", keys.search_global, function()
        require("fzf-lua").grep { cmd = "rg --column --line-number --no-heading -t c --color=always --smart-case -- " }
      end)
    end,
    group = file_grp,
  })

  au_cmd("FileType", {
    pattern = { "cpp" },
    callback = function()
      bmap("n", keys.search_global, function()
        require("fzf-lua").grep { cmd = "rg --column --line-number --no-heading -t cpp --color=always --smart-case -- " }
      end)
    end,
    group = file_grp,
  })

  local cb = function()
    bmap("n", keys.lsp_goto_definition, function()
      require("fzf-lua").lsp_definitions { jump_to_single_result = true }
    end)
    bmap("n", keys.lsp_goto_references, function()
      require("fzf-lua").lsp_references { jump_to_single_result = true }
    end)
    bmap("n", keys.lsp_impl, function()
      require("fzf-lua").lsp_implementations { jump_to_single_result = true }
    end)
  end

  require("utils.lsp").register_attach_cb(cb)
end

return M
