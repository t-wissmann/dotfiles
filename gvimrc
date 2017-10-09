
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

set anti guifont=xos4\ Terminus\ 11,Envy\ Code\ R\ 10,Mono\ 12,Inconsolata\ 12
set anti guifont=

