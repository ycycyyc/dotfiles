vim9script

$FZF_DEFAULT_OPTS = "--layout=reverse"
g:fzf_preview_window = [ "up:45%", "ctrl-/" ]   
g:fzf_commits_log_options = "--color --pretty=format:'%C(yellow)%h%Creset  %C(blue)<%an>%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s  %C(auto)%d'"
g:fzf_layout = { 'window': { 'width': 0.95, 'height': 0.85  }  }

def RipgrepFzf(query: string, fullscreen: number)
    var command_fmt = 'rg --hidden --column --line-number --no-heading --color=always --smart-case -- %s || true'
    var initial_command = printf(command_fmt, shellescape(query))
    var reload_command = printf(command_fmt, '{q}')
    var spec = {'options': ['--phony', '--query', query, '--bind', 'change:reload:' .. reload_command]}
    fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), fullscreen)
enddef

command! -nargs=* -bang Find RipgrepFzf(<q-args>, <bang>0)

def GlobalSearch(...args: list<string>)
    var rg = "rg -H --hidden --column --line-number --no-heading --color=always --smart-case -F "
    var ignore = 0
    var index = 0
    var querys: list<string>

    for arg in args
        if ignore == 1 
            ignore = 0
        elseif arg == "-t" 
            ignore = 1
            if args[ index + 1 ] == "go"
                rg = rg .. " -t go"
            elseif args[ index + 1 ] == "cpp"
                rg = rg .. " -t c -t cpp"
            endif
        elseif arg == "-g" 
            ignore = 1
            rg = rg .. " -g " .. "'" .. args[ index + 1 ] .. "'"
        else
            querys->add(arg)
        endif
        index = index + 1
    endfor

    if querys->len() == 0 
        RipgrepFzf("", 0)
        return
    endif

    var query = ""
    var firstWord = true
    for q in querys
        if firstWord
            firstWord = false
            query = q
        else
            query = query .. " " .. q 
        endif
    endfor

    rg = rg .. " -- " .. "'" .. query .. "'"
    fzf#vim#grep(rg, 1, fzf#vim#with_preview(), 0)
enddef

command! -nargs=* Rg GlobalSearch(<f-args>)

nnoremap <silent> <leader>hh :Commits<cr>
