local M = {}

local keys = require "basic.keys"
local helper = require "utils.helper"
local env = require("basic.env").env

M.fzf_config = function()
  vim.g.coc_fzf_opts = { "--layout=reverse" }
  vim.g.coc_fzf_preview = "up:40%"
  vim.g.coc_fzf_preview_fullscreen = 0
  vim.g.coc_fzf_preview_toggle_key = "ctrl-/"
end

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

M.coc_config = function()
  -- global plugin
  local global_extensions = {
    "coc-git",
    "coc-pairs",
    "coc-go",
    "coc-clangd",
    "coc-marketplace",
    "coc-yank",
    "coc-explorer",
    "coc-json",
    "coc-yaml",
  }

  if env.coclist == true then
    table.insert(global_extensions, "coc-lists")
  end

  vim.g.coc_global_extensions = global_extensions

  local keyset = vim.keymap.set
  local bmap = helper.build_keymap { noremap = true, buffer = true }
  local register_fts_cb = require("yc.settings").register_fts_cb

  -- cmp
  local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
  keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
  keyset("i", "<c-j>", [["\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
  keyset("i", "<c-k>", [[coc#pum#stop()]], { silent = true, expr = true })
  keyset("i", "<c-l>", [[CocActionAsync('showSignatureHelp')]], { silent = true, expr = true })

  -- lsp
  keyset("n", keys.lsp_hover, show_docs, { silent = true })
  keyset("n", keys.lsp_goto_definition, "<Plug>(coc-definition)", { silent = true })
  keyset("n", keys.lsp_goto_type_definition, "<Plug>(coc-type-definition)", { silent = true })
  keyset("n", keys.lsp_impl, "<Plug>(coc-implementation)", { silent = true })
  keyset("n", keys.lsp_goto_references, "<Plug>(coc-references)", { silent = true })
  keyset("n", keys.lsp_err_goto_prev, "<Plug>(coc-diagnostic-prev)", { silent = true })
  keyset("n", keys.lsp_err_goto_next, "<Plug>(coc-diagnostic-next)", { silent = true })
  keyset("n", keys.lsp_rename, "<Plug>(coc-rename)", { silent = true })
  keyset("n", keys.lsp_code_action, "<Plug>(coc-codeaction-cursor)", { silent = true })
  vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

  -- lsp format
  register_fts_cb({ "go", "typescript" }, function()
    bmap("n", keys.lsp_format, ":Format<cr>:w<cr>")
  end)

  -- lsp range format
  register_fts_cb({ "h", "cpp", "hpp", "c", "typescript" }, function()
    bmap("x", keys.lsp_range_format_cpp, "<Plug>(coc-format-selected)")
  end)

  -- lsp switch source header
  register_fts_cb({ "h", "cpp", "hpp", "c" }, function()
    bmap("n", keys.switch_source_header, ":CocCommand clangd.switchSourceHeader<cr>")
  end)

  -- coc-git
  keyset("n", keys.git_next_chunk, "<Plug>(coc-git-nextchunk)")
  keyset("n", keys.git_prev_chunk, "<Plug>(coc-git-prevchunk)")
  keyset("n", keys.git_reset_chunk, ":CocCommand git.chunkUndo<cr>")
  keyset("n", keys.git_preview_hunk, ":CocCommand git.chunkInfo<cr>")

  -- coc-outline
  keyset("n", keys.toggle_symbol, ":CocOutline<cr>")

  -- coc-explorer
  keyset("n", keys.toggle_dir, ":CocCommand explorer<cr>")

  -- coc color
  vim.cmd [[
    hi link CocErrorHighlight   clear
    hi link CocWarningHighlight  clear
    hi link CocInfoHighlight  clear
    hi link CocHintHighlight   clear
  ]]

  -- coc-lists
  if env.coclist == true then
    keyset("n", keys.search_resume, ":CocListResume<cr>")
    keyset("n", keys.jump_to_next_qf, ":CocNext<cr>")
    keyset("n", keys.jump_to_prev_qf, ":CocPrev<cr>")
    keyset("n", keys.search_find_files, ":CocList files<cr>")
    keyset("n", keys.search_global, ":CocList grep ")
    keyset("n", keys.search_cur_word, ":CocList grep <c-r><c-w><cr>", { silent = false })
    keyset("n", keys.switch_buffers, ":CocList buffers<cr>")
    keyset("n", keys.search_buffer, ":CocList lines<cr>")
  else
    vim.fn["coc_fzf#common#add_list_source"]("fzf-grep", "search global", "Rg")

    keyset("n", keys.search_resume, ":CocFzfListResume<cr>")
    keyset("n", keys.search_cur_word, ":CocFzfList fzf-grep <c-r><c-w><cr>")
    keyset("n", keys.search_global, ":CocFzfList fzf-grep ")
  end

  -- coc semantic token
  vim.g.coc_default_semantic_highlight_groups = 0
  local hlMap = {
    Namespace = { "@namespace", "Include" },
    Type = { "@type", "Type" },
    Enum = { "@type", "Type" },
    Interface = { "@type", "Type" },
    Struct = { "@structure", "Type" },
    Class = { "@not_exit", "Type" },
    EnumMember = { "@not_exists", "Constant" },
    TypeParameter = { "@parameter", "Identifier" },
    Parameter = { "@parameter", "Identifier" },
    Variable = { "@variable", "Identifier" },
    Property = { "@property", "Identifier" },
    Event = { "@keyword", "Keyword" },
    Function = { "@function", "Function" },
    Method = { "@method", "Function" },
    Macro = { "@constant.macro", "Define" },
    Keyword = { "@keyword", "Keyword" },
    Modifier = { "@storageclass", "StorageClass" },
    Comment = { "@comment", "Comment" },
    String = { "@string", "String" },
    Number = { "@number", "Number" },
    Boolean = { "@boolean", "Boolean" },
    Regexp = { "@string.regex", "String" },
    Operator = { "@operator", "Operator" },
    Decorator = { "@symbol", "Identifier" },
    Deprecated = { "@text.strike", "CocDeprecatedHighlight" },
  }

  for key, value in pairs(hlMap) do
    local ts = value[1]
    local fallback = value[2]
    local link = fallback

    if vim.fn["coc#highlight#valid"](ts) == 1 then
      link = ts
    end

    vim.api.nvim_set_hl(0, "CocSem" .. key, { link = link, default = true })
  end
end

return M
