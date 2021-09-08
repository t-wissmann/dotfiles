
set runtimepath^=~/.vim/bundle/gruvbox/
colorscheme gruvbox
source ~/.vimrc
"let g:solarized_visibility="high"    "default value is normal
"set bg=dark
"colorscheme solarized
"colorscheme molokai

" remove all guielements
set guioptions+=m
set guioptions-=T
set guioptions-=r
set guioptions-=R

function! EnterTexFile()
	"set keywordprg=dict
    set cul
endfunction

" set anti guifont=xos4\ Terminus\ 11,Envy\ Code\ R\ 10,Mono\ 12,Inconsolata\ 12
" set anti guifont=xos4\ Terminus\ 11,Envy\ Code\ R\ 10,Mono\ 12,Inconsolata\ 12
set anti guifont=Inconsolata\ 12
" set anti guifont=


if has("unix")
    function! FontSizePlus ()
      let l:gf_size_whole = matchstr(&guifont, '\( \)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole + 1
      let l:new_font_size = ' '.l:gf_size_whole
      let &guifont = substitute(&guifont, ' \d\+$', l:new_font_size, '')
    endfunction

    function! FontSizeMinus ()
      let l:gf_size_whole = matchstr(&guifont, '\( \)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole - 1
      let l:new_font_size = ' '.l:gf_size_whole
      let &guifont = substitute(&guifont, ' \d\+$', l:new_font_size, '')
    endfunction
else
    function! FontSizePlus ()
      let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole + 1
      let l:new_font_size = ':h'.l:gf_size_whole
      let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
    endfunction

    function! FontSizeMinus ()
      let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole - 1
      let l:new_font_size = ':h'.l:gf_size_whole
      let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
    endfunction
endif


if has("gui_running")
    " Ctrl-minus
    nnoremap zo :call FontSizeMinus()<CR>
    nnoremap zi :call FontSizePlus()<CR>
    
endif
