" fzf
let $FZF_DEFAULT_OPTS="--layout=reverse"
let g:fzf_preview_window=[ "up:40%", "ctrl-/" ]   
let g:fzf_commits_log_options="--color --pretty=format:'%C(yellow)%h%Creset  %C(blue)<%an>%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s  %C(auto)%d'"
let g:fzf_layout = { 'window': { 'width': 0.95, 'height': 0.85  }  }

function! RipgrepFzf(query, fullscreen)
    let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction
command! -nargs=* -bang Find call RipgrepFzf(<q-args>, <bang>0)

command! -bang -nargs=* Rghidden
  \ call fzf#vim#grep(
  \   'rg --hidden --column --line-number --no-heading --glob=!.git/ --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Rggo
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading -t go --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Rgcpp
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading -t cpp -t c --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Rgrust
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading -t rust --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Rgnosmartcase
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

command! -bang -nargs=* GitGrep
  \ call fzf#vim#grep(
  \   'git grep -i  --untracked --line-number --color=always --threads=8 -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)
