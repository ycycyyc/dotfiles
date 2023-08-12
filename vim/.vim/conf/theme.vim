" theme
function! s:onedark_theme() 

    set background=dark
    set cursorline
    set cursorlineopt=number
    " local red = { n = 204, gui = "#ff5f87" }
    " local blue = { n = 39, gui = "#00afff" }
    " local black = { n = 235, gui = "#262626" }
    " local dark_yellow = { n = 173, gui = "#d7875f" }
    " local yellow = { n = 180, gui = "#d7af87" }
    " local comment_grey = { n = 59, gui = "#5f5f5f" }
    " local menu_grey = { n = 237, gui = "#3a3a3a" }
    " local menu_grey2 = { n = 233, gui = "#121212" }
    " local green = { n = 114, gui = "#87d787" }
    " local white = { n = 145, gui = #afafaf"" }
    " local cyan = { n = 38, gui = #00afd7"" }
    " local purple = { n = 170, gui = #d75fd7"" }
    " local cursor_grey = { n = 236, gui = #303030"" }
    " local curent_line = { n = 11, gui = #ffff00"" }
    hi  Constant ctermfg=38
    hi  Error ctermfg=204
    hi  Identifier ctermfg=204
    hi  String ctermfg=114

    hi PreProc ctermfg=180
    hi PreCondit ctermfg=180
    hi Type ctermfg=180
    hi Typedef ctermfg=180
    hi Structure ctermfg=180
    hi StorageClass ctermfg=180

    hi Number ctermfg=173
    hi Character ctermfg=173
    hi Boolean ctermfg=173
    hi SpecialChar ctermfg=173

    hi Comment ctermfg=245
    hi SpecialComment ctermfg=204

    hi Function ctermfg=39
    hi Special ctermfg=39
    hi Include ctermfg=39

    hi Statement ctermfg=170
    hi Conditional ctermfg=170
    hi Repeat ctermfg=170
    hi Label ctermfg=170
    hi Operator  ctermfg=170
    hi Keyword  ctermfg=170
    hi Exception ctermfg=170
    hi Define ctermfg=170
    hi Macro ctermfg=170
    hi Todo ctermfg=170

    hi SignColumn ctermbg=237
    hi LineNr ctermbg=237 ctermfg=59

    hi ColorColumn ctermbg=236  
    hi MatchParen ctermfg=145 cterm=underline ctermbg=None

    " hi CocMenuSel ctermbg=237
    hi CocMenuSel ctermbg=39 ctermfg=236
    hi CursorLineNr ctermbg=237 ctermfg=11 cterm=None


    hi DiffAdd ctermfg=114 ctermbg=237
    hi DiffDelete ctermfg=204 ctermbg=237
    hi DiffChange ctermbg=237 ctermfg=180
    
    " coc sem highlight
    " CocCommand semanticTokens.checkCurrent
    hi CocSemVariable ctermfg=145
    hi CocSemParameter ctermfg=145
    hi CocSemClass ctermfg=180

    " athom/more-colorful.vim enhance go highlight
    " hi Comment ctermfg=59 

    set colorcolumn=80
    set nu
    set relativenumber

    hi! StatusLine1 ctermfg=145 ctermbg=239 cterm=bold
    hi! StatusLine2 ctermfg=39 ctermbg=238
    hi! StatusLine3 ctermfg=145 ctermbg=236 

    set stl=%#StatusLine1#\ %{expand('%:~:.')}%m%h\ \ %#StatusLine2#\ %l\ of\ %L\ %#StatusLine3#

endfunction

call s:onedark_theme()
