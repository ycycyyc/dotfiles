set nocompatible

" disable internal plug
let g:loaded_matchparen=1
let g:loaded_matchit=1
let g:loaded_netrwPlugin=1

let g:coc_data_home = "~/.config/coc_vim/"

if $VIM_LSP == "lsp"
    call plug#begin('~/.vim/lsp_plugged')
    Plug 'ycycyyc/lsp'
    Plug 'airblade/vim-gitgutter'
    Plug 'jiangmiao/auto-pairs'
    Plug 'lambdalisue/fern.vim'
else
    call plug#begin('~/.vim/plugged')
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'antoinemadec/coc-fzf', {'branch': 'master'}
endif
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'voldikss/vim-floaterm', {'on': 'FloatermToggle'}
Plug 'schickling/vim-bufonly', {'on': 'BufOnly'}
Plug 'octol/vim-cpp-enhanced-highlight', {'for': ['cpp', 'c'] }
Plug 'easymotion/vim-easymotion', {'on': '<Plug>(easymotion-overwin-f2)'}

call plug#end()

inoremap jk <ESC>
map <space> <leader>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
let loaded_netrwPlugin=1
nnoremap <c-p> :Files<CR>
nnoremap <leader>b :BLines<CR>
nnoremap <leader>f :Rg<space>
nnoremap gw :Rg <c-r><c-w><cr>
nnoremap gW :BLines <c-r><c-w><cr>
nnoremap <leader>o :Buffers<cr>
nnoremap <leader>/ :GitGrep<space>
inoremap <c-e> <esc>A
inoremap <c-a> <esc>I
inoremap <c-f> <right>
nnoremap <leader>m `
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L $

nnoremap <bs> :noh<cr>
nnoremap Y y$
vnoremap <bs> <esc>
nnoremap <leader>[ :bp<cr>
nnoremap <leader>] :bn<cr>
xnoremap <leader>s :s/.*'\(.*\)'.*/\1

" -- 交换内容，先删除内容1，再选中内容2，然后用<leader>x交换
xnoremap <leader>x <ESC>`.``gvp``P
nnoremap <leader>x viw<ESC>`.``gvp``P<c-o>

cnoremap <c-e> <End>
cnoremap <c-a> <Home>

command! Cnext try | cnext | catch | cfirst | catch | endtry
command! Cprev try | cprev | catch | clast | catch | endtry

nnoremap <silent> <leader>j :Cnext<cr>
nnoremap <silent> <leader>k :Cprev<cr>

set tabstop=4
set softtabstop=4
set sw=4
set expandtab
set encoding=utf-8
set hidden
set nobackup
set nowritebackup
set noswapfile
set cmdheight=1
set updatetime=300
set shortmess+=c
set backspace=indent,eol,start
set smartindent
set autoindent
set ignorecase
set smartcase
set laststatus=2
set hlsearch
set signcolumn=yes
" set confirm
set incsearch
set splitright

" theme
function! s:default_theme() 
    " set background=dark
    hi SignColumn ctermbg=237
    hi Pmenu ctermbg=237 ctermfg=145
    hi PmenuSel ctermbg=39 ctermfg=236
    hi MatchParen ctermfg=204 cterm=underline ctermbg=None
    hi Comment ctermfg=59
endfunction

" call s:default_theme()
" colorscheme codedark
" hi Type ctermfg=43 guifg=#4EC9B0

hi DiffAdd ctermfg=114 ctermbg=237
hi DiffDelete ctermfg=204 ctermbg=237
hi DiffChange ctermbg=237 ctermfg=180
hi default link cCustomClass Type
hi default link GitSignsAdd DiffAdd
hi default link GitSignsChange DiffChange
hi default link GitSignsDelete GitSignsDelete
set statusline=%f%m%h\ \ %l\ of\ %L

" my settings
au FileType qf wincmd J
au FileType help wincmd L
au FileType * set fo-=o
au FileType qf nnoremap <silent> <buffer> q :q<cr>

if $VIM_LSP == "lsp"
    exe 'source' "~/dotfiles/vim/.vim/conf/lsp.vim"
else
    exe 'source' "~/dotfiles/vim/.vim/conf/coc.vim"
endif

exe 'source' "~/dotfiles/vim/.vim/conf/fzf.vim"
exe 'source' "~/dotfiles/vim/.vim/conf/other.vim"
exe 'source' "~/dotfiles/vim/.vim/conf/theme.vim"

function! SynStack ()
    for i1 in synstack(line("."), col("."))
        let i2 = synIDtrans(i1)
        let n1 = synIDattr(i1, "name")
        let n2 = synIDattr(i2, "name")
        echo n1 "->" n2
    endfor
endfunction
" map gm :call SynStack()<CR>
command! Inspect :call SynStack()
