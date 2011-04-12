
" enforce 8 colors
set t_Co=8

set number
syntax on
set hlsearch
set autoindent
set nocompatible
set showmatch
set shiftwidth=4
set tabstop=4
filetype plugin on
set foldmethod=indent
set modeline
set nofoldenable
set backup

set list
set listchars=tab:>-,trail:-

" menu and completion
set wildmenu
set wildmode=longest:full

set et
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
hi StatusLineNC ctermbg=black ctermfg=yellow cterm=bold
hi StatusLine ctermbg=yellow ctermfg=black cterm=NONE
"
" for tabs
hi TabLine ctermbg=black ctermfg=white cterm=bold
hi TabLineFill ctermbg=black cterm=NONE
hi TabLineSel ctermbg=green ctermfg=black cterm=NONE
" yellow line numbers
hi LineNr ctermbg=NONE term=NONE ctermfg=yellow cterm=bold



