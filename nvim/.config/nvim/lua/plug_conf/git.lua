-- git
local M = {}

M.config = function()
  local keys = require "basic.keys"

  require("gitsigns").setup {
    signs = {
      add = { hl = "GitSignsAdd", text = "+", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
      change = { hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
      delete = { hl = "GitSignsDelete", text = "-", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
      topdelete = { hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
      changedelete = { hl = "GitSignsChange", text = "_", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
    },

    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      map("n", keys.git_next_chunk, function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return "<Ignore>"
      end, { expr = true })

      map("n", keys.git_prev_chunk, function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return "<Ignore>"
      end, { expr = true })

      map("n", keys.git_reset_chunk, gs.reset_hunk)
      map("n", keys.git_preview_hunk, gs.preview_hunk)
    end,
  }
end

M.fugitive_config = function()
  local keys = require "basic.keys"
  vim.keymap.set("n", keys.git_blame, ":Git blame<cr>")

  local function showFugitiveGit()
    if vim.fn.FugitiveHead() ~= "" then
      vim.cmd "G"
      vim.cmd "wincmd L"
    end
  end

  local function toggleFugitiveGit()
    if vim.fn.buflisted(vim.fn.bufname "fugitive:///*/.git//$") ~= 0 then
      local helper = require "utils.helper"

      --  如果当前window为fugitiv就关闭
      local winnums = helper.get_winnums_byft "fugitive"
      local cur_win = vim.api.nvim_get_current_win()
      for _, winn in ipairs(winnums) do
        if cur_win == winn then
          vim.cmd [[ execute ":bdelete" bufname('fugitive:///*/.git//$') ]]
          return
        end
      end

      require("utils.helper").try_jumpto_ft_win "fugitive"
    else
      showFugitiveGit()
    end
  end

  vim.keymap.set("n", keys.git_status, toggleFugitiveGit, {})

  require("yc.settings").register_fts_cb({ "fugitive", "fugitiveblame" }, function()
    local helper = require "utils.helper"
    local bmap = helper.build_keymap { noremap = true, buffer = true }
    bmap("n", "q", ":q<cr>")

    bmap("n", "<leader>d", function()
      local current_line = vim.api.nvim_get_current_line()
      local items = vim.fn.split(current_line)

      local cmd = "DiffviewOpen -- " .. items[2]
      vim.print("Run cmd: " .. cmd)
      vim.cmd(cmd)
    end)
  end)
end

return M
