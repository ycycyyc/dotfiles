" lsp plugin
let lspServers = [
    \     #{
    \        filetype: ['go', 'gomod'],
    \        path: 'gopls',
    \        args: ['serve'],
    \        initializationOptions: {'analyses': {'shadow': v:true, 'unusedparams': v:true, 'nilness': v:true, 'printf': v:true, 'unusedwrite': v:true, 'fieldalignment': v:false}, 'staticcheck': v:true }
    \      },
    \     #{
    \        filetype: ['c', 'cpp', 'h'],
    \        path: 'clangd',
    \        args: ['--background-index', '--suggest-missing-includes', '-j=15', '--all-scopes-completion', '--function-arg-placeholders', '--pch-storage=memory', '--header-insertion=iwyu', '--completion-style=detailed']
    \      }
    \   ]

let lspOpts = {'autoHighlightDiags': v:true, 'outlineOnRight': v:true, 'usePopupInCodeAction': v:true, 'ignoreMissingServer': v:true, 'outlineWinSize': 80, 'noNewlineInCompletion': v:true}
autocmd VimEnter * call LspOptionsSet(lspOpts)
autocmd VimEnter * call LspAddServer(lspServers)
hi link LspDiagLine clear

nnoremap gd             :LspGotoDefinition<cr>
nnoremap gy             :LspGotoTypeDef<cr>
nnoremap ]g             :LspDiagNext<cr>
nnoremap [g             :LspDiagPrev<cr>
nnoremap gr             :LspShowReferences<cr>
nnoremap <leader>rn     :LspRename<cr>
nnoremap <leader>i      :LspGotoImpl<cr>
nnoremap <leader>d      :LspCodeAction<cr>
nnoremap K              :LspHover<cr>
nnoremap <leader>t      :LspOutline<cr>
nnoremap <leader>c      :LspSwitchSourceHeader<cr>

autocmd FileType go nnoremap <buffer> <leader><space>  :LspFormat<cr>
autocmd FileType c,cpp,h xnoremap <buffer> f :LspFormat<cr>

" git 
let g:gitgutter_preview_win_floating = 1


