" vim-floaterm
nnoremap <c-t> :FloatermToggle<cr>
tnoremap <c-t> <c-\><c-n>:FloatermToggle<cr>
let g:floaterm_autoclose=2
let g:floaterm_height=0.8
let g:floaterm_width=0.8

autocmd QuitPre * call <sid>TermForceCloseAll()
function! s:TermForceCloseAll() abort
    let term_bufs = filter(range(1, bufnr('$')), 'getbufvar(v:val, "&buftype") == "terminal"')
        for t in term_bufs
            execute "bd! " t
        endfor
endfunction

" wildfire
let g:wildfire_objects = ["i'", 'i"',"iw","iW", "i)", "i]", "i}", "ip", "it"]
vmap <tab> <Plug>(wildfire-water)

" cpp hi enhance
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1

" easymotion
" nmap <Leader>e <Plug>(easymotion-overwin-w)
nmap <leader>e <Plug>(easymotion-overwin-f2)
let g:EasyMotion_smartcase = 1
let g:EasyMotion_keys = 'fjkoimveldwugnhsrtybc,xaFLMHNEBGzqpDJIYRAQT'

" hi EasyMotionTarget ctermfg=235 ctermbg=196
hi EasyMotionTarget ctermfg=235 ctermbg=170 cterm=bold
hi link EasyMotionShade cleard

" better esc
" let g:better_escape_shortcut = 'jk'
" let g:better_escape_interval = 250

" fugitive
function! ToggleGStatus()
    if buflisted(bufname('.git/index'))
        bd .git/index
    else
        G
        wincmd L
    endif
endfunction
command ToggleGStatus :call ToggleGStatus()
nnoremap <leader>g :ToggleGStatus<CR>
nnoremap <leader>l :Git blame<cr>


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
  nmap <buffer> o <Plug>(fern-my-open-or-expand)

endfunction

augroup fern-custom
  autocmd! *
  autocmd FileType fern call s:init_fern()
augroup END
