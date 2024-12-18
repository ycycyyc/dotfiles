local keys = YcVim.keys

local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
local buf_map = YcVim.map.buf

local M = {
  user_cmds = {
    {
      "Format",
      "call CocAction('format')",
      {},
    },
  },
  keymaps = {
    -- cmp
    { "i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts },
    { "i", "<c-j>", [["\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts },
    { "i", "<c-k>", [[coc#pum#stop()]], { silent = true, expr = true } },
    { "i", "<c-l>", [[CocActionAsync('showSignatureHelp')]], { silent = true, expr = true } },
    { "i", "<c-n>", [[coc#pum#visible() ? coc#pum#next(1) : "\<C-n>"]], { silent = true, expr = true } },
    { "i", "<c-p>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"]], { silent = true, expr = true } },
    { "n", keys.lsp_toggle_inlay_hint, ":CocCommand document.toggleInlayHint<cr>" },

    -- coc-git
    { "n", keys.git_next_chunk, "<Plug>(coc-git-nextchunk)", {} },
    { "n", keys.git_prev_chunk, "<Plug>(coc-git-prevchunk)", {} },
    { "n", keys.git_reset_chunk, ":CocCommand git.chunkUndo<cr>", {} },
    { "n", keys.git_preview_hunk, ":CocCommand git.chunkInfo<cr>", {} },

    -- coc-outline
    { "n", keys.toggle_symbol, ":CocOutline<cr>", {} },

    -- coc-explorer
    -- { "n", keys.toggle_dir_open_file, ":CocCommand explorer --preset floating<cr>", {} },
    -- { "n", keys.toggle_dir, ":CocCommand explorer --preset floating --reveal-when-open<cr>", {} },
  },
  initfuncs = {
    {
      -- lsp format
      { "go", "typescript" },
      function()
        buf_map("n", keys.lsp_format, ":Format<cr>:w<cr>")
        buf_map("x", keys.lsp_range_format, function() end)
      end,
    },
    {
      -- lsp range format
      { "h", "cpp", "hpp", "c", "typescript" },
      function()
        buf_map("x", keys.lsp_range_format, "<Plug>(coc-format-selected)")
        buf_map("n", keys.lsp_format, function() end)
      end,
    },

    {
      { "h", "cpp", "hpp", "c" },
      function()
        buf_map("n", keys.switch_source_header, ":CocCommand clangd.switchSourceHeader<cr>")
      end,
    },
    {
      "coctree",
      function()
        buf_map("n", "q", ":q<cr>")
      end,
    },
    {
      "coc-explorer",
      function()
        local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
        local bufnr = vim.api.nvim_get_current_buf()

        vim.api.nvim_create_autocmd("CursorMoved", {
          group = vim.api.nvim_create_augroup("show_dir_coc_explorer", { clear = true }),
          buffer = bufnr,
          callback = function(args)
            local info = vim.fn["CocAction"]("runCommand", "explorer.getNodeInfo", 0)
            if info == vim.NIL then
              return
            end

            local set = function(title)
              local winid = vim.api.nvim_get_current_win()
              local config = vim.api.nvim_win_get_config(winid)
              local new_config = vim.tbl_deep_extend("force", config, {
                title = title,
                border = "rounded",
              })
              vim.api.nvim_win_set_config(winid, new_config)
            end

            if info and info.fullpath then
              local is = vim.fn.split(info.fullpath, "/")
              table.remove(is, #is)
              local path = table.concat(is, "/")
              set(path)
            end
          end,
        })
      end,
    },
  },
}

local setup_semantic_token = function()
  -- coc semantic token
  vim.g.coc_default_semantic_highlight_groups = 0
  local hlMap = {
    TypeNamespace = { "@namespace", "Identifier" },
    TypeType = { "@type", "Type" },
    TypeVariable = { "@variable", "Identifier" },
    TypeEnum = { "@type", "Type" },
    TypeInterface = { "@type", "Type" },
    TypeStruct = { "@structure", "Type" },
    TypeClass = { "@not_exit", "Type" },
    TypeEnumMember = { "@not_exists", "Constant" },
    TypeTypeParameter = { "@parameter", "Identifier" },
    TypeParameter = { "@parameter", "Identifier" },
    TypeProperty = { "@property", "Identifier" },
    TypeEvent = { "@keyword", "Keyword" },
    TypeFunction = { "@function", "Function" },
    TypeMethod = { "@method", "Function" },
    TypeMacro = { "@constant.macro", "Define" },
    TypeKeyword = { "@keyword", "Keyword" },
    TypeModifier = { "@storageclass", "StorageClass" },
    TypeComment = { "@comment", "Comment" },
    TypeString = { "@string", "String" },
    TypeNumber = { "@number", "Number" },
    TypeBoolean = { "@boolean", "Boolean" },
    TypeRegexp = { "@string.regex", "String" },
    TypeOperator = { "@operator", "Operator" },
    TypeDecorator = { "@symbol", "Identifier" },
    TypeDeprecated = { "@text.strike", "CocDeprecatedHighlight" },
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

M.config = function()
  -- global plugin
  local global_extensions = {
    "coc-git",
    "coc-pairs",
    "coc-go",
    "coc-clangd",
    "coc-marketplace",
    -- "coc-yank",
    -- "coc-explorer",
    "coc-json",
    "coc-yaml",
  }

  vim.g.coc_global_extensions = global_extensions

  -- coc color
  vim.api.nvim_set_hl(0, "CocErrorHighlight", { link = "clear" })
  vim.api.nvim_set_hl(0, "CocWarningHighlight", { link = "clear" })
  vim.api.nvim_set_hl(0, "CocInfoHighlight", { link = "clear" })
  vim.api.nvim_set_hl(0, "CocHintHighlight", { link = "clear" })

  -- snippet
  vim.g.coc_snippet_next = "<TAB>"
  vim.g.coc_snippet_prev = "<S-TAB>"

  vim.g.coc_explorer_global_presets = {
    floating = {
      position = "floating",
      ["open-action-strategy"] = "sourceWindow",
    },
  }

  -- coc settings
  vim.opt.pumheight = 10

  -- coc-pairs
  vim.b.coc_pairs = {
    { "(", ")" },
    { "{", "}" },
    { "[", "]" },
    { "'", "'" },
    { "`", "`" },
  }

  -- coc semantic token
  setup_semantic_token()
  YcVim.setup_plugin(M)
end

return M
