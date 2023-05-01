set nocompatible

if $VIM_LSP == "lsp"
    call plug#begin('~/.vim/lsp_plugged')
    Plug 'ycycyyc/lsp'
    Plug 'airblade/vim-gitgutter'
    Plug 'jiangmiao/auto-pairs'
else
    call plug#begin('~/.vim/plugged')
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'antoinemadec/coc-fzf', {'branch': 'release'}
endif
Plug 'lambdalisue/fern.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'voldikss/vim-floaterm'
Plug 'gcmt/wildfire.vim'
Plug 'schickling/vim-bufonly'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'easymotion/vim-easymotion'
call plug#end()

inoremap jk <ESC>
map <space> <leader>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
let loaded_netrwPlugin=1
nnoremap <c-p> :GitFiles<CR>
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

" theme
function! s:default_theme() 

    hi SignColumn ctermbg=237
    hi DiffAdd ctermfg=114 ctermbg=237
    hi DiffDelete ctermfg=204 ctermbg=237
    hi DiffChange ctermbg=237 ctermfg=180
    hi Pmenu ctermbg=237 ctermfg=145
    hi PmenuSel ctermbg=39 ctermfg=236
    hi MatchParen ctermfg=204 cterm=underline ctermbg=None
    set statusline=%f%m%h\ total:\ %L\ row:\ %l
    set background=light

endfunction

call s:default_theme()

" my settings
au FileType qf wincmd J

if $VIM_LSP == "lsp"
    exe 'source' "~/.vim/conf/lsp.vim"
else
    exe 'source' "~/.vim/conf/coc.vim"
endif

exe 'source' "~/.vim/conf/fzf.vim"
exe 'source' "~/.vim/conf/other.vim"
