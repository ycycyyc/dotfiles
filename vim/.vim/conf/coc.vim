let g:coc_config_home="~/dotfiles/nvim/.config/nvim"
" coc_fzf
let g:coc_fzf_opts=['--layout=reverse']
let g:coc_fzf_location_delay=20

call coc_fzf#common#add_list_source('fzf-grep', 'display open buffers', 'Rg')
nnoremap <leader>f :CocFzfList fzf-grep<space>
nnoremap <leader>l :CocFzfListResume<cr>
nnoremap gw :CocFzfList fzf-grep <c-r><c-w><cr>

" coc
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

inoremap <silent><expr> <c-j>  "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" map for coc-snippets
" inoremap <silent><expr> <TAB>
"       \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : "\<TAB>" 

let g:coc_snippet_next = '<TAB>'
let g:coc_snippet_prev = '<S-TAB>'

set pumheight=10

inoremap  <expr> <c-k> coc#pum#stop()

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> <leader>i <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

nmap <leader>rn <Plug>(coc-rename)
xmap f  <Plug>(coc-format-selected)

augroup cocVim
  autocmd!
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  autocmd FileType go,typescript nnoremap <buffer> <leader><space> :Format<cr>:w<cr>
  autocmd FileType coctree nnoremap <buffer> q :q<cr>
  " autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp') 
augroup end

nmap <leader>d  <Plug>(coc-codeaction-cursor)

command! -nargs=0 Format :call CocAction('format')
inoremap <silent><expr> <c-l>  CocActionAsync('showSignatureHelp')

nnoremap <silent> <leader>t :CocOutline<cr>
nnoremap <silent> <leader>s :CocFzfList outline<cr>

" coc-go coc-clangd coc plugin settings
let g:coc_global_extensions=["coc-git", "coc-pairs", "coc-go", "coc-clangd", "coc-json", "coc-explorer", "coc-marketplace", "coc-yank", "coc-vimlsp", "coc-tsserver"]
nnoremap <silent> ]c <Plug>(coc-git-nextchunk)
nnoremap <silent> [c <Plug>(coc-git-prevchunk)
nnoremap <silent> <leader>hu :CocCommand git.chunkUndo<cr>
nnoremap <silent> <leader>hp :CocCommand git.chunkInfo<cr>

nnoremap <silent> <leader>N :CocCommand explorer <cr>
nnoremap <silent> <leader>n :CocCommand explorer --reveal-when-open<cr>
nnoremap <silent> <leader>c :CocCommand clangd.switchSourceHeader<cr>

" hi coc
hi link CocErrorHighlight   CocBold
hi link CocWarningHighlight  CocBold
hi link CocInfoHighlight  CocBold
hi link CocHintHighlight   CocBold

let g:coc_default_semantic_highlight_groups=0

hi default CocSemTypeEnum ctermfg=180
hi default CocSemTypeClass ctermfg=180
hi default CocSemTypeType ctermfg=180
hi default CocSemTypeParameter cterm=bold ctermfg=145
hi default CocSemTypeNamespace ctermfg=204
hi default CocSemTypeProperty ctermfg=204
hi default CocSemTypeFunction ctermfg=39
hi default CocSemTypeMethod ctermfg=39
hi default CocSemTypeProperty ctermfg=39

hi default CocSemTypeVariable ctermfg=145

hi default link CocSemTypeKeyword Keyword
hi default link CocSemTypeEnumMember Constant
hi default link CocSemTypeModifier StorageClass
hi default link CocSemTypeMacro PreProc

hi default link CocSemTypeOperator Operator

hi default link cStructure Statement
hi default link cppStructure Statement
hi default link cStorageClass Statement
hi default link cppStorageClass Statement
hi default link cppModifier Statement
hi cType ctermfg=170
hi cppType ctermfg=170

hi default link goBlock CocSemTypeVariable
