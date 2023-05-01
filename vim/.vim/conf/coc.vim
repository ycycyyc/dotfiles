let g:coc_config_home="~/dotfiles/nvim/.config/nvim"
" coc_fzf
let g:coc_fzf_opts=['--layout=reverse']
nnoremap <leader>p :CocFzfList<cr>

" coc
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

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

augroup mygroup
  autocmd!
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp') 
augroup end

nmap <leader>d  <Plug>(coc-codeaction-cursor)

command! -nargs=0 Format :call CocActionAsync('format')
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
inoremap <silent><expr> <c-l>  CocActionAsync('showSignatureHelp')

nnoremap <silent> <leader>t :CocOutline<cr>

" coc-go coc-clangd coc plugin settings
let g:coc_global_extensions=["coc-git", "coc-pairs", "coc-go", "coc-clangd"]

nnoremap <silent> ]c <Plug>(coc-git-nextchunk)
nnoremap <silent> [c <Plug>(coc-git-prevchunk)
nnoremap <silent> <leader>hu :CocCommand git.chunkUndo<cr>
nnoremap <silent> <leader>hp :CocCommand git.chunkInfo<cr>

nnoremap <leader>n :CocCommand explorer<cr>
nnoremap <leader>c :CocCommand clangd.switchSourceHeader<cr>

" hi coc
hi link CocErrorHighlight   CocBold
hi link CocWarningHighlight  CocBold
hi link CocInfoHighlight  CocBold
hi link CocHintHighlight   CocBold
