local keys = require "basic.keys"
local helper = require "utils.helper"

local function show_docs()
  local cw = vim.fn.expand "<cword>"
  if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
    vim.api.nvim_command("h " .. cw)
  elseif vim.api.nvim_eval "coc#rpc#ready()" then
    vim.fn.CocActionAsync "doHover"
  else
    vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
  end
end

local M = {
  keymaps = {
    { "n", keys.search_resume, ":CocFzfListResume<cr>", {} },
    { "n", keys.search_cur_word, ":CocFzfList fzf-grep <c-r><c-w><cr>", {} },
    { "n", keys.search_global, ":CocFzfList fzf-grep ", {} },

    -- coc outline
    { "n", keys.lsp_symbols, ":CocFzfList outline<cr>", {} },

    { "n", keys.lsp_hover, show_docs, { silent = true } },
    { "n", keys.lsp_goto_definition, "<Plug>(coc-definition)", { silent = true } },
    { "n", keys.lsp_goto_type_definition, "<Plug>(coc-type-definition)", { silent = true } },
    { "n", keys.lsp_impl, "<Plug>(coc-implementation)", { silent = true } },
    { "n", keys.lsp_goto_references, "<Plug>(coc-references)", { silent = true } },
    { "n", keys.lsp_err_goto_prev, "<Plug>(coc-diagnostic-prev)", { silent = true } },
    { "n", keys.lsp_err_goto_next, "<Plug>(coc-diagnostic-next)", { silent = true } },
    { "n", keys.lsp_rename, "<Plug>(coc-rename)", { silent = true } },
    { "n", keys.lsp_code_action, "<Plug>(coc-codeaction-cursor)", { silent = true } },
  },
}

M.config = function()
  vim.g.coc_fzf_opts = { "--layout=reverse" }
  vim.g.coc_fzf_preview = "up:45%"
  vim.g.coc_fzf_preview_fullscreen = 0
  vim.g.coc_fzf_preview_toggle_key = "ctrl-/"

  vim.fn["coc_fzf#common#add_list_source"]("fzf-grep", "search global", "Rg")

  helper.setup_m(M)
end

return M
