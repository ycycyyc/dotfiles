local M = {}

M.config = function()
  local helper = require "utils.helper"
  local map = helper.build_keymap { noremap = true }
  local bmap = helper.build_keymap { noremap = true, buffer = true }
  local user_cmd_bind = vim.api.nvim_create_user_command
  local user_cmd = function(name, cb)
    local opt = { nargs = "*", bang = true }
    user_cmd_bind(name, cb, opt)
  end
  local keys = require "basic.keys"

  -- " 让输入上方，搜索列表在下方
  vim.env.FZF_DEFAULT_OPTS = "--layout=reverse"
  vim.g.fzf_preview_window = { "up:40%", "ctrl-/" }

  local preview = {
    layout = "up:+{2}-/2",
    vertical = "up:45%",
  }

  if vim.fn.executable "bat" == 1 then
    preview["default"] = "bat"
  end

  require("fzf-lua").setup {
    winopts = {
      row = 0.25,
      col = 0.6,
      width = 0.92, -- window width
      height = 0.95, -- window height
      fullscreen = false,
      preview = preview,
    },
    grep = {
      no_header_i = true,
    },
    fzf_opts = {
      ["--info"] = "default",
    },
    git = {
      commits = {
        actions = {
          ["ctrl-y"] = function(selected)
            local res = vim.fn.split(selected[1], " ")
            vim.fn.setreg(0, res[1])
          end,
        },
      },
    },
  }

  map("n", keys.search_find_files, "<cmd>FzfLua files<cr>")
  map("n", keys.search_buffer, "<cmd>FzfLua grep_curbuf<cr>")
  map("n", keys.switch_buffers, "<cmd>FzfLua buffers<cr>")

  local build_rg_func = function(opt)
    return function(args)
      require("fzf-lua").grep {
        cmd = "rg --hidden --glob=!.git/  --column --line-number --no-heading "
          .. opt
          .. " --color=always --smart-case -- ",
        search = args["args"],
      }
    end
  end

  user_cmd("Rg", build_rg_func "")
  user_cmd("Rgcpp", build_rg_func " -t cpp -t c ")
  user_cmd("Rggo", build_rg_func " -t go ")
  user_cmd("GitGrep", function(args)
    require("fzf-lua").grep {
      cmd = "git grep -i --untracked --color=always --line-number --threads=8 -- ",
      search = args["args"],
      no_esc = true,
    }
  end)
  user_cmd_bind("Buffers", function()
    require("fzf-lua").buffers()
  end, {})
  user_cmd_bind("Commits", function()
    require("fzf-lua").git_commits()
  end, {})

  map("n", keys.search_global, ":Rg ")
  map("n", keys.search_git_grep, ":GitGrep ")

  local register_fts_cb = require("yc.settings").register_fts_cb
  register_fts_cb("go", function()
    bmap("n", keys.search_global, ":Rggo ")
  end)
  register_fts_cb({ "h", "cpp", "hpp", "c" }, function()
    bmap("n", keys.search_global, ":Rgcpp ")
  end)

  local cb = function(_, _, kms)
    kms[keys.lsp_goto_definition] = {
      function()
        require("fzf-lua").lsp_definitions { jump_to_single_result = true }
      end,
      "n",
    }

    kms[keys.lsp_goto_references] = {
      function()
        require("fzf-lua").lsp_references { jump_to_single_result = true }
      end,
      "n",
    }

    kms[keys.lsp_impl] = {
      function()
        require("fzf-lua").lsp_implementations { jump_to_single_result = true }
      end,
      "n",
    }

    kms[keys.lsp_code_action] = {
      function()
        require("fzf-lua").lsp_code_actions {}
      end,
      "n",
    }
  end

  require("utils.lsp").register_attach_cb(cb)
end

return M
