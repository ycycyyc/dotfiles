local M = {}

M.config = function()
  local helper = require "utils.helper"
  local map = helper.build_keymap { noremap = true }
  local bmap = helper.build_keymap { noremap = true, buffer = true }
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
      -- ["--delimiter"] = ":",
      -- ["--nth"] = "4..",
    },
    git = {
      commits = {
        actions = {
          ["ctrl-y"] = function(selected)
            local res = vim.fn.split(selected[1], " ")
            vim.fn.setreg(0, res[1])
            helper.diff_open()
          end,
        },
      },
    },
  }

  map("n", keys.search_find_files, "<cmd>FzfLua files<cr>")
  map("n", keys.search_buffer, "<cmd>FzfLua grep_curbuf<cr>")
  map("n", keys.search_cur_word_cur_buf, function()
    require("fzf-lua").grep_curbuf {
      search = vim.fn.expand "<cword>",
      fzf_opts = {
        ["--delimiter"] = ":",
        ["--nth"] = "3..",
      },
    }
  end)

  map("n", keys.switch_buffers, "<cmd>FzfLua buffers<cr>")
  map("n", keys.search_resume, "<cmd>FzfLua resume<cr>")

  vim.api.nvim_create_user_command("Rg", function(args)
    local rg = {
      "rg",
      "-H",
      "--hidden",
      "--column",
      "--line-number",
      "--no-heading",
      "--glob=!.git/",
      "--color=always",
      "--smart-case",
    }

    local fargs = args["fargs"]
    local content = {}
    local ignore = 0
    local islive = false
    local filepath = ""

    -- TODO(yc) grep 'main -t' 怎么处理?
    for i, value in ipairs(fargs) do
      if ignore > 0 then
        ignore = 0
      elseif value == "-t" then
        ignore = 1
        if fargs[i + 1] == "go" then
          table.insert(rg, "-t go")
        elseif fargs[i + 1] == "cpp" then
          table.insert(rg, "-t cpp -t c")
        elseif fargs[i + 1] == "lua" then
          table.insert(rg, "-t lua")
        end
      elseif value == "-g" then
        ignore = 1
        table.insert(rg, "--glob='" .. fargs[i + 1] .. "'")
      elseif value == "-i" then
        islive = true
      elseif value == "--" then
        ignore = 1
        filepath = fargs[i + 1]
      else
        table.insert(content, value)
      end
    end

    table.insert(rg, "-- ")
    local cmd = table.concat(rg, " ")

    local query = table.concat(content, " ")

    if query == "" then
      islive = true
    end

    if islive then
      require("fzf-lua").live_grep {
        cmd = cmd,
        search = query,
        filespec = filepath,
      }
      return
    end

    require("fzf-lua").grep {
      cmd = cmd,
      search = query,
      filespec = filepath,
    }
  end, { nargs = "*", bang = true })

  vim.api.nvim_create_user_command("Buffers", function()
    require("fzf-lua").buffers()
  end, { nargs = "*", bang = true })

  vim.api.nvim_create_user_command("Commits", function()
    require("fzf-lua").git_commits()
  end, {})
  vim.keymap.set("n", keys.git_commits, function()
    require("fzf-lua").git_commits()
  end, { silent = false })

  vim.api.nvim_create_user_command("History", ":FzfLua command_history", {})

  map("n", keys.search_global, ":Rg ")
  map("n", keys.search_cur_word, ":Rg <c-r><c-w><cr>")

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

  require("utils.lsp").register_lsp_client_cb(cb)
end

return M
