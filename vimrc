
au VimEnter *.clj set ft=clojure
au VimEnter *.fr set ft=haskell
au VimEnter *.scala set ft=scala
au BufRead,BufNewFile *.v set ft=coq
" enforce 8 colors
"set t_Co=8
"set t_Co=256

set encoding=utf-8
set ttimeoutlen=50

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
set nojoinspaces
" only insert real tabs at the beginning of a line and fill with spaces
" otherwise
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
        "getline('.')[0:col('.')-2] =~ '^\t*$' ? "\<Tab>" : repeat(" ", &sw - ((virtcol('.')-1) % &sw))
    else
        return "\<c-x>\<c-o>"
    endif
endfunction

inoremap <tab> <c-r>=InsertTabWrapper()<cr>
"inoremap <expr> <tab> getline('.')[0:col('.')-2] =~ '^\t*$' ? "\<Tab>" : repeat(" ", &sw - ((virtcol('.')-1) % &sw))

" enable filetype specific features
filetype plugin on
" automagical omnicompletion
"set ofu=syntaxcomplete#Complete

" show a readable Beep! e.g. if finding a char via fx fails
set debug=beep

" code folding
set foldmethod=indent
set nofoldenable
"map <C-l> zA
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
set listchars=tab:>\ ,trail:·,nbsp:_
"set listchars=tab:▸\ ,eol:¬

" menu and completion -> bash-like
set wildmenu
set wildmode=longest,list
set wildignorecase

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
"map t <ESC>:tabnew 

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

set runtimepath^=~/.vim/bundle/elm.vim.git/
"set runtimepath^=~/.vim/bundle/minibufexpl/

set runtimepath^=~/.vim/bundle/gruvbox/
"silent !~/.vim/bundle/gruvbox/gruvbox_256palette.sh &
colorscheme gruvbox
let g:gruvbox_contrast_dark="hard"
let g:gruvbox_contrast_light="hard"
let g:gruvbox_number_column="bg3"


set background=dark

hi LineNr ctermbg=233 guibg=Black
hi Normal ctermbg=NONE term=NONE
hi VertSplit ctermbg=NONE ctermfg=black cterm=NONE
hi Visual ctermbg=black cterm=None
hi StatusLineNC ctermbg=black ctermfg=white cterm=NONE
hi StatusLine ctermbg=black ctermfg=green cterm=bold
set fillchars+=vert:│

cnoreabbrev reload source ~/.vimrc


""" " My colorscheme
""" hi Normal ctermbg=NONE term=NONE cterm=NONE
""" hi CursorLine ctermbg=black term=NONE cterm=NONE
""" " yellow line numbers
""" hi LineNr ctermbg=black term=NONE ctermfg=gray cterm=NONE
""" hi CursorLineNr ctermbg=black term=NONE ctermfg=green cterm=bold
""" hi Pmenu ctermbg=black ctermfg=white term=NONE cterm=NONE
""" hi PmenuSel ctermbg=green ctermfg=0 term=NONE cterm=NONE
""" hi PmenuThumb ctermbg=red term=NONE cterm=bold
""" 
""" " colors for folded brackets
""" hi Folded ctermbg=0 term=NONE cterm=NONE ctermfg=gray
""" " color of border in vertical split
""" hi VertSplit ctermbg=NONE ctermfg=black cterm=NONE
""" set fillchars+=vert:│
""" hi Todo ctermbg=yellow ctermfg=black cterm=bold
""" hi StatusLineNC ctermbg=black ctermfg=white cterm=NONE
""" hi StatusLine ctermbg=black ctermfg=yellow cterm=bold
""" " color for tabs and trailing spaces, also see: listchars
""" hi SpecialKey ctermbg=NONE ctermfg=blue cterm=NONE
""" "
""" " for tabs
""" hi TabLine ctermbg=black ctermfg=white cterm=bold
""" hi TabLineFill ctermbg=black cterm=NONE
""" hi TabLineSel ctermbg=green ctermfg=black cterm=NONE
""" " somehow, these hi lines are overwritten somewhere later
""" "hi Constant ctermfg=blue ctermbg=blue cterm=NONE
""" "hi Statement ctermfg=green ctermbg=NONE cterm=NONE
""" "hi Comment ctermfg=brown ctermbg=NONE cterm=NONE

au VimEnter *.tex :call EnterTexFile()
au VimEnter *.csv :call EnterCSVFile()
au VimEnter *.hs  :call EnterHsFile()
au VimEnter /tmp/mutt* :call ComposeMessage()
au VimEnter *.tex set nocursorline


function! EnterCSVFile()
    hi CSVColumnEven cterm=bold ctermbg=NONE guibg=NONE ctermfg=7
    hi CSVColumnOdd  cterm=NONE ctermbg=NONE guibg=NONE ctermfg=7
    hi CSVColumnHeaderEven cterm=bold,underline ctermbg=NONE guibg=NONE ctermfg=3
    hi CSVColumnHeaderOdd  cterm=underline ctermbg=NONE guibg=NONE ctermfg=3
endfunction

function! EnterHsFile()
    set et
    set shiftwidth=2
    set tabstop=2
endfunction

set runtimepath^=~/.vim/bundle/LaTeX-Box.git/

function! EnterTexFile()
	"set keywordprg=dict
	set wrap
	"set ai " Auto indent
	"set si " Smart indent
	"set laststatus=2 " we want *always* a status bar even if I am not in splitscreen mode
	"we don't because you can get filename, and stats using ctrl g
	"iab newide <esc>:r ~/.vim/templates/newide<Cr>kdd
	"ab xenum \begin{enumerate}<return><tab>\item<return><C-U>\end{enumerate}<up><end>
	ab xenum \begin{enumerate}<return>\item<return>\end{enumerate}<up><end>
	ab xitem \begin{itemize}<return>\item<return>\end{itemize}<up><end>
	ab xdesc \begin{description}<return><tab>\item<return><C-U>\end{description}<up><end>
	ab xdia \begin{diagram}<return>\end{diagram}<up><end>
	ab xi\ \item
	ab xcent \begin{center}<RETURN><RETURN><C-U>\end{center}<UP><END>
	ab xalign \begin{align*}\end{align*}<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><RETURN><UP><END>
	ab xals \begin{align*}<RETURN><C-U>\end{align*}<UP><END>
	ab xma \[\]<LEFT><LEFT><RETURN><UP><END>
	ab xtcd \begin{tikzcd}\end{tikzcd}<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><RETURN><UP><END>
	ab xsec \section{}<left>
	ab xsub \subsection{}<left>
	ab xssub \subsubsection{}<left>
	ab xframe \begin{frame}{}<RETURN><TAB><RETURN><C-U>\end{frame}<UP><UP><END><LEFT>
	ab xblock \begin{block}{}<RETURN><TAB><RETURN><C-U>\end{block}<UP><UP><END><LEFT>
	ab xablock \begin{alertblock}{}<RETURN><TAB><RETURN><C-U>\end{alertblock}<UP><UP><END><LEFT>
	ab xlst \lstinputblock{}<LEFT>
	ab dt \d t
    let g:LatexBox_split_type="new"
    set nocul
endfunction

function! ComposeMessage()
	set spell

	iab cu Gruß,<CR>Thorsten
	iab cuv Viele Grüße,<CR>Thorsten
	iab cuw Viele Grüße,<CR>Thorsten Wißmann
	iab xwe Schönes Wochenende,<CR>Thorsten
	iab xsprech http://wwwcip.cs.fau.de/admin/index.html.en
	iab xfaq http://wwwcip.cs.fau.de/doc/faq.html.en
	iab xtofu -- <CR>A. Because it breaks the logical sequence of discussion<RETURN>Q. Why is top posting bad?

endfunction

au FileType clojure filetype plugin indent on
au FileType clojure :call EditClojure()

function! EditClojure()
    syntax on
    set autoindent
    set tabstop=2
    set shiftwidth=2
    let g:vimclojure#ParenRainbow = 1
    " nailgun
    let vimclojure#WantNailgun = 1
    let vimclojure#NailgunServer = "127.0.0.1"
    let vimclojure#NailgunPort = "2113"
    " buffer
    let vimclojure#SplitPos = "left"
    let vimclojure#SplitSize = 10

    vmap <C-c><C-c> "ry :call Send_to_Screen(@r)<CR>
    nmap <C-c><C-c> vip<C-c><C-c>

    let g:screen_sessionname = "clj"
    let g:screen_windowname = "clj"

    nmap <C-c>v :call Screen_Vars()<CR>
endfunction

function! Screen_Vars()
  if !exists("g:screen_sessionname") || !exists("g:screen_windowname")
    let g:screen_sessionname = ""
    let g:screen_windowname = "0"
  end

  let g:screen_sessionname = input("session name: ", "", "custom,Screen_Session_Names")
  let g:screen_windowname = input("window name: ", g:screen_windowname)
endfunction

function! Send_to_Screen(text)

  echo system("screen -S clj -p clj -X stuff '" . substitute(a:text, "'", "'\\\\''", 'g') . "'")
endfunction

" Spell Check
let b:myLang=0
let g:myLangList=["nospell","de_de","en_gb"]
function! ToggleSpell()
  let b:myLang=b:myLang+1
  if b:myLang>=len(g:myLangList) | let b:myLang=0 | endif
  if b:myLang==0
    setlocal nospell
  else
    execute "setlocal spell spelllang=".get(g:myLangList, b:myLang)
  endif
  echo "spell checking language:" g:myLangList[b:myLang]
endfunction

map <F7> :call ToggleSpell()<CR>
imap <F7> <ESC>:call ToggleSpell()<CR>a


" minibufexplorer options
"map <F9> :MBEToggle<CR>
"map <C-J> :bn<CR>
"map <C-K> :bp<CR>
"
"let g:miniBufExplStatusLineText = "MiniBufExpl"
"let g:miniBufExplVSplit = 1
"let g:miniBufExplMinSize = 10
"let g:miniBufExplMaxSize = 50
"let g:miniBufExplShowBufNumbers = 1
"
"hi MBENormal ctermbg=None term=None cterm=None ctermfg=Gray
"hi MBEChanged ctermbg=None term=None cterm=None ctermfg=DarkYellow
"hi MBEVisibleNormal ctermbg=None term=None cterm=None ctermfg=DarkGreen
"hi MBEVisibleChanged ctermbg=None term=None cterm=None ctermfg=DarkGreen
"hi def link MBEVisibleActiveNormal None


if has("autocmd")
	augroup GPGASCII
		au!
		au BufReadPre *.gpg set viminfo=
		au BufReadPre *.gpg set noswapfile
		au BufReadPost *.gpg  :%!gpg -q -d 2> /dev/null
		au BufReadPost *.gpg  |redraw
		au BufWritePre *.gpg  :%!gpg -q -e -a -r 1caff810
		au BufWritePre *.gpg  let @f=expand("%:t")
		au BufWritePre *.gpg  1 s/^/\=@f ."\r\r"/
		au BufWritePost *.gpg u
	augroup END
endif " has ("autocmd")


" vimpager
" --------
let vimpager_passthrough = 0
if exists("vimpager")
    "let vimpager_scrolloff = 0
    "let g:less_enabled=0
    set nonu
    call <SNR>1_End()
endif


au VimEnter *.tex execute "nmap ZE :! VIM_KEY='ZE' synctex-katarakt-vim " . v:servername . " 2>/dev/null >/dev/null &<LEFT><LEFT>"

" CTRLP configuration
set runtimepath^=~/.vim/bundle/ctrlp.vim
nmap <C-O> :CtrlPBuffer<CR>
hi CtrlPMode1 cterm=bold ctermfg=blue ctermbg=black guibg=black
hi CtrlPMode2 cterm=bold ctermfg=red ctermbg=black guibg=black
hi CtrlPStatus cterm=bold ctermfg=yellow ctermbg=black guibg=black
let g:ctrlp_match_window = 'bottom,order:btt,min:2,max:20'
let g:ctrlp_switch_buffer = '0'

noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
" some spacemacs keys
noremap <space>w <C-w>
noremap <space>bp <C-^>
noremap <space>bn <C-^>

set showcmd

" Use OmniCompletion for abook dictionary entries
" Fire omnicompletion using ^X^O
au BufRead /tmp/mutt* setlocal omnifunc=QueryCommandComplete

