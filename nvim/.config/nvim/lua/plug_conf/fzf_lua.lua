local M = {}

M.config = function()
  local helper = require "utils.helper"
  local map = helper.build_keymap { noremap = true }
  local silent_map = helper.build_keymap { noremap = true, silent = true }
  local keys = require "basic.keys"

  -- " 让输入上方，搜索列表在下方
  vim.env.FZF_DEFAULT_OPTS = "--layout=reverse"
  vim.g.fzf_preview_window = { "up:45%", "ctrl-/" }

  local preview = {
    layout = "up:+{2}-/2",
    vertical = "up:45%",
  }

  if vim.fn.executable "bat" == 1 then
    preview["default"] = "bat"
  end

  local diff = function(selected)
    local res = vim.fn.split(selected[1], " ")
    vim.fn.setreg(0, res[1])
    helper.diff_open()
  end

  require("fzf-lua").setup {
    winopts = {
      row = 0.3,
      col = 0.5,
      width = 0.8, -- window width
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
    lsp = {
      _cached_hls = {}, -- fzf-lua更新到新版本？
      symbols = {
        symbol_style = 3, -- remove icon
      },
    },
    git = {
      commits = {
        cmd = "git log -C --color --pretty=format:'%C(yellow)%h%Creset  %C(blue)<%an>%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s  %C(auto)%d'",
        actions = {
          ["ctrl-y"] = diff,
          ["default"] = diff,
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

  map("n", keys.lsp_symbols, "<cmd>FzfLua lsp_document_symbols<cr>")
  map("n", keys.lsp_global_symbols, "<cmd>FzfLua lsp_live_workspace_symbols<cr>")

  map("n", keys.switch_buffers, "<cmd>FzfLua buffers<cr>")
  map("n", keys.search_resume, "<cmd>FzfLua resume<cr>")

  vim.api.nvim_create_user_command("Rg", function(args)
    ---@type string[]
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

    ---@type string[]
    local fargs = args["fargs"]
    ---@type string[]
    local content = {}
    ---@type 0 | 1
    local ignore = 0
    ---@type boolean
    local islive = false
    ---@type string
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
        elseif fargs[i + 1] == "vim" then
          table.insert(rg, "-t vim")
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
    ---@type string
    local cmd = table.concat(rg, " ")

    ---@type string
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

  vim.keymap.set("n", keys.cmd_history, ":FzfLua command_history<cr>", { silent = true })

  map("n", keys.search_global, ":Rg ")
  silent_map("n", keys.search_cur_word, ":Rg <c-r><c-w><cr>")

  ---@type Yc.ClientLspConfCb
  local cb = function(_, _, kms, _)
    local opt = {
      jump_to_single_result = true,
      -- lua/fzf-lua/providers/lsp.lua#location_handler#opts.filter
      filter = function(items)
        for _, item in ipairs(items) do
          if item.filename then
            item.filename = require("fzf-lua.utils").ansi_codes.magenta(item.filename)
          end
        end
        return items
      end,
    }

    kms[keys.lsp_goto_definition] = {
      function()
        require("fzf-lua").lsp_definitions(opt)
      end,
      "n",
    }

    kms[keys.lsp_goto_references] = {
      function()
        require("fzf-lua").lsp_references(opt)
      end,
      "n",
    }

    kms[keys.lsp_impl] = {
      function()
        require("fzf-lua").lsp_implementations(opt)
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
