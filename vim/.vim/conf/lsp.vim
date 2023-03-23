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

nnoremap gd             :LspGotoDefinition<cr>
nnoremap gy             :LspGotoTypeDef<cr>
nnoremap ]g             :LspDiagNext<cr>:LspDiagCurrent<cr>
nnoremap [g             :LspDiagPrev<cr>:LspDiagCurrent<cr>
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

" nerdtree 
" nnoremap <leader>n :NERDTreeToggle<cr>
"
nnoremap <leader>n :Fern . -drawer -toggle<cr>

let g:fern#default_hidden = 1
let g:fern#default_exclude = '.git$'

function! s:init_fern() abort
  " Use 'select' instead of 'edit' for default 'open' action
  nmap <buffer> <Plug>(fern-action-open) <Plug>(fern-action-open:select)
  " nmap <buffer> a <Plug>(fern-action-new-path)

  nmap <buffer><expr>
    \ <Plug>(fern-my-expand-or-collapse)
    \ fern#smart#leaf(
    \   "\<Plug>(fern-action-collapse)",
    \   "\<Plug>(fern-action-expand)",
    \   "\<Plug>(fern-action-collapse)",
    \ )

  nmap <buffer><expr> <Plug>(fern-my-open-or-expand)
	\ fern#smart#leaf(
	\   "<Plug>(fern-action-open)",
	\   "<Plug>(fern-my-expand-or-collapse)",
	\ )

  nmap <buffer> <cr> <Plug>(fern-my-open-or-expand)

endfunction

augroup fern-custom
  autocmd! *
  autocmd FileType fern call s:init_fern()
augroup END

