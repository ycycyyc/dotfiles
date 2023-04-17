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
