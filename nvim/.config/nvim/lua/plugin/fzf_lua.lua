---@param find YcVim.Finder
local live_grep = function(find)
  require("fzf-lua").live_grep {
    cmd = find:cmd(),
    no_esc = true,
    search = find.query,
    filespec = find.filepath,
  }
end

---@param find YcVim.Finder
local grep = function(find)
  require("fzf-lua").grep {
    cmd = find:cmd(),
    no_esc = true,
    search = find.query,
    filespec = find.filepath,
  }
end

local grep_buf_word = function()
  require("fzf-lua").grep_curbuf {
    search = vim.fn.expand "<cword>",
    fzf_opts = {
      ["--delimiter"] = ":",
      ["--nth"] = "3..",
    },
  }
end

---@type YcVim.SetupOpt
local setup = {}

setup.user_cmds = {
  {
    "Buffers",
    function()
      require("fzf-lua").buffers()
    end,
    { nargs = "*", bang = true },
  },

  {
    "Commits",
    function()
      require("fzf-lua").git_commits()
    end,
    {},
  },

  {
    "Rg",
    YcVim.rg.run(live_grep, grep),
    { nargs = "*", bang = true },
  },
}

local build_opt = function()
  local word = vim.fn.expand "<cword>"
  local color_word = require("fzf-lua.utils").ansi_codes.red(word)

  local color_item = function(item)
    -- lua/fzf-lua/providers/lsp.lua#location_handler#opts.filter 文件名紫色字体
    item.filename = require("fzf-lua.utils").ansi_codes.magenta(item.filename)

    local new_text, cnt = string.gsub(item.text, word, color_word)
    if cnt == 0 then --应该不会走到这
      vim.print "should never be here"
      return
    end

    if cnt == 1 then
      item.text = new_text
      return
    end

    local startIndex = item.col -- 匹配到的word开始的index
    local nextIndex = item.col + #word -- word的下一个index

    item.text = string.sub(item.text, 1, startIndex - 1) -- 开头或者空字符串
      .. color_word -- 带颜色的word
      .. string.sub(item.text, nextIndex) -- 结束或者空字符串
  end

  return {
    jump_to_single_result = true,
    filter = function(items)
      for _, item in ipairs(items) do
        color_item(item)
      end
      return items
    end,
  }
end

local init = function()
  local lsp_action = YcVim.lsp.action

  lsp_action.definition = function()
    require("fzf-lua").lsp_definitions {
      jump_to_single_result = true,
    }
  end

  lsp_action.references = function()
    require("fzf-lua").lsp_references(build_opt())
  end

  lsp_action.impl = function()
    require("fzf-lua").lsp_implementations(build_opt())
  end

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.select = function(...)
    -- load fzf-lua, 并且替换 vim.ui.select
    require("fzf-lua").register_ui_select()
    return vim.ui.select(...)
  end
end

local config = function()
  -- " 让输入上方，搜索列表在下方
  vim.env.FZF_DEFAULT_OPTS = "--layout=reverse"
  vim.g.fzf_preview_window = { "up:45%", "ctrl-/" }

  local diff = function(selected)
    local res = vim.fn.split(selected[1], " ")
    YcVim.git.commit_diff(res[1])
  end

  local actions = require "fzf-lua.actions"
  require("fzf-lua").setup {
    winopts = {
      row = 0.3,
      col = 0.5,
      width = 0.8, -- window width
      height = 0.95, -- window height
      fullscreen = false,
      preview = {
        layout = "up:+{2}-/2",
        vertical = "up:45%",
      },
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
      status = {
        actions = {
          ["ctrl-l"] = { fn = actions.git_unstage, reload = true },
          ["ctrl-h"] = { fn = actions.git_stage, reload = true },
        },
      },
      commits = {
        cmd = "git log -C --color --pretty=format:'%C(yellow)%h%Creset  %C(blue)<%an>%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s  %C(auto)%d'",
        actions = {
          ["ctrl-y"] = diff,
          ["default"] = diff,
        },
      },
    },
  }

  YcVim.setup(setup)
end

local keys = YcVim.keys

return {
  "ycycyyc/fzf-lua",
  lazy = true,
  keys = {
    { keys.pick_open, "<cmd>FzfLua<cr>" },
    { keys.pick_resume, "<cmd>FzfLua resume<cr>" },
    { keys.pick_files, "<cmd>FzfLua files<cr>" },
    { keys.pick_lines, "<cmd>FzfLua grep_curbuf<cr>" },
    { keys.lsp_symbols, "<cmd>FzfLua lsp_document_symbols<cr>" },
    { keys.lsp_finder, "<cmd>FzfLua lsp_finder<cr>" },
    { keys.lsp_global_symbols, "<cmd>FzfLua lsp_live_workspace_symbols<cr>" },
    { keys.git_commits, ":Commits<cr>" },
    { keys.pick_grep, ":Rg " },
    { keys.pick_grep_word, ":Rg <c-r><c-w><cr>" },
    { keys.pick_cmd_history, ":FzfLua command_history<cr>" },
    { keys.pick_grep_word_cur_buf, grep_buf_word },
  },
  cmd = YcVim.lazy.cmds(setup.user_cmds, { "FzfLua" }),
  config = config,
  init = init,
}
