
" enforce 8 colors
set t_Co=8

set hidden
" show line numbers
set number
" always do syntaxhighlighting
syntax on
" highlight all search matches
set hlsearch
" keep indentation when opening new lines
set autoindent
" set some vi-modes
set nocompatible
" show matching brackets
set showmatch
" set width of tabs
set et
set shiftwidth=4
set tabstop=4
" enable filetype specific features
filetype plugin on
" automagical omnicompletion
"set ofu=syntaxcomplete#Complete

" code folding
set foldmethod=indent
set nofoldenable
" show statusbar with current row,col
set modeline

let hostname = substitute(system('hostname'), '\n', '', '')
if hostname == "mephisto"
    set nobackup
elseif hostname == "faui02"
    set nobackup
elseif hostname == "faui03"
    set nobackup
elseif hostname == "faui09"
    set nobackup
else
    " create backupfiles
    set backup
endif

" highlight whitespaces and trailing spaces
set list
set listchars=tab:»\ ,trail:·,nbsp:%
"set listchars=tab:▸\ ,eol:¬

" menu and completion -> bash-like
set wildmenu
set wildmode=longest:full

set visualbell t_vb=

set scrolloff=2
" ignorecase:
set ignorecase
set smartcase


if has('mouse')
    set mouse=a
endif


" selecting links
nmap - <C-]>
nmap <F5> <ESC>:e<CR>
map t <ESC>:tabnew 

" line and column-numbers on bottom right
set ruler

" ignore filetypes on tab completion
set wildignore =*.o,*.class,*~

" abkürzungen
ab #i #include
ab #d #define
set foldmethod=indent

" hi folds ctermbg=0
set cursorline
hi CursorLine ctermbg=black term=NONE cterm=NONE

" colors for folded brackets
hi Folded ctermbg=0 term=NONE cterm=NONE
" color of border in vertical split
hi VertSplit ctermbg=NONE ctermfg=red cterm=NONE
hi Todo ctermbg=yellow ctermfg=black cterm=bold
hi StatusLineNC ctermbg=black ctermfg=white cterm=bold
hi StatusLine ctermbg=black ctermfg=yellow cterm=NONE
" color for tabs and trailing spaces, also see: listchars
hi SpecialKey ctermbg=NONE ctermfg=blue cterm=bold
"
" for tabs
hi TabLine ctermbg=black ctermfg=white cterm=bold
hi TabLineFill ctermbg=black cterm=NONE
hi TabLineSel ctermbg=green ctermfg=black cterm=NONE
" yellow line numbers
hi LineNr ctermbg=NONE term=NONE ctermfg=yellow cterm=bold



