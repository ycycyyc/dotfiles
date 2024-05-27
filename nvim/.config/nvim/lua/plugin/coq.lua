local M = {}

local env = require("basic.env").env

M.init = function()
  if not env.coq then
    return
  end

  if env.python3 ~= "" then
    vim.g.python3_host_prog = env.python3
  end

  vim.g.coq_settings = {
    auto_start = "shut-up",
    keymap = {
      pre_select = false,
      recommended = false,
      bigger_preview = "<c-]>",
      manual_complete = "<c-]>",
      jump_to_mark = "<c-]>",
    },
    clients = {
      tmux = {
        enabled = false,
      },
      tree_sitter = {
        enabled = false,
        weight_adjust = -2,
      },
      buffers = {
        enabled = false,
        weight_adjust = -2,
      },
      snippets = {
        warn = {}, -- delete warn msg
      },
      lsp = {
        weight_adjust = 2,
      },
    },
    completion = { skip_after = { "{", "[", "}", "]", "=" } },
    display = {
      preview = { enabled = true },
      pum = { y_max_len = 8 },
      ghost_text = { enabled = false },
      icons = {
        mode = "none",
      },
    },
  }
  vim.o.completeopt = "menu,menuone,noselect"
end

M.config = function()
  local remap = vim.api.nvim_set_keymap
  local npairs = require "nvim-autopairs"
  npairs.setup { map_bs = false, map_cr = false, map_c_w = true }
  _G.MUtils = {}

  MUtils.CR = function()
    if vim.fn.pumvisible() ~= 0 then
      if vim.fn.complete_info({ "selected" }).selected ~= -1 then
        return npairs.esc "<c-y>"
      else
        -- return npairs.esc "<c-e>" .. npairs.autopairs_cr()
        return npairs.esc "<c-n>" .. npairs.esc "<c-y>"
      end
    else
      return npairs.autopairs_cr()
    end
  end
  remap("i", "<cr>", "v:lua.MUtils.CR()", { expr = true, noremap = true })

  MUtils.BS = function()
    if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ "mode" }).mode == "eval" then
      return npairs.esc "<c-e>" .. npairs.autopairs_bs()
    else
      return npairs.autopairs_bs()
    end
  end
  remap("i", "<bs>", "v:lua.MUtils.BS()", { expr = true, noremap = true })

  MUtils.CJ = function()
    if vim.fn.pumvisible() ~= 0 then
      return npairs.esc "<c-j>" .. npairs.autopairs_cr()
    else
      return npairs.autopairs_cr()
    end
  end
  remap("i", "<c-j>", "v:lua.MUtils.CJ()", { expr = true, noremap = true })

  vim.cmd [[ ino <silent><expr> <c-k>    pumvisible() ? Preview_preview() : '<C-X><C-U>' ]]
end

return M
