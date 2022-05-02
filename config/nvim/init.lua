-- 
vim.api.nvim_exec(
[[
au VimEnter *.clj set ft=clojure
au VimEnter *.fr set ft=haskell
au VimEnter *.scala set ft=scala
au BufRead,BufNewFile *.v set ft=coq
" enforce 8 colors
set t_Co=8
"set t_Co=256

set encoding=utf-8
set ttimeoutlen=50

set scrolloff=2

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
set et shiftwidth=4 tabstop=4 nojoinspaces

" show a readable Beep! e.g. if finding a char via fx fails
"set debug=beep


" highlight whitespaces and trailing spaces
set list
set listchars=tab:>\ ,trail:·,nbsp:_
"set listchars=tab:▸\ ,eol:¬

" menu and completion -> bash-like
set wildmenu
set wildmode=longest,list
set wildignorecase

set breakindent
set showbreak=..

set cursorline

hi LineNr ctermbg=233 guibg=Black
hi Normal ctermbg=NONE term=NONE
hi VertSplit ctermbg=NONE ctermfg=black cterm=NONE
hi Visual ctermbg=black cterm=None
hi StatusLineNC ctermbg=black ctermfg=white cterm=NONE
hi StatusLine ctermbg=black ctermfg=green cterm=bold
hi CursorLine ctermbg=black term=NONE cterm=NONE
hi LineNr ctermbg=black term=NONE ctermfg=gray cterm=NONE
hi CursorLineNr ctermbg=black term=NONE ctermfg=green cterm=bold

set fillchars+=vert:│


noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
" some spacemacs keys
noremap <space>w <C-w>
map <space>bp :bp<CR>
map <space>bn :bn<CR>

]],
true)

return require('packer').startup(function()
  -- configuration of packer https://github.com/wbthomason/packer.nvim
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'
end)
