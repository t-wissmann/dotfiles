-- 
vim.api.nvim_exec(
[[

if has('mouse')
    set mouse=a
endif


au VimEnter *.clj set ft=clojure
au VimEnter *.fr set ft=haskell
au VimEnter *.scala set ft=scala
au BufRead,BufNewFile *.v set ft=coq
" enforce 8 colors
"set t_Co=8
set t_Co=256

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
colorscheme gruvbox

hi LineNr ctermbg=233 guibg=Black
hi Normal ctermbg=NONE term=NONE
hi VertSplit ctermbg=NONE ctermfg=black cterm=NONE
hi Visual ctermbg=black cterm=None
hi StatusLineNC ctermbg=black ctermfg=white cterm=NONE
hi StatusLine ctermbg=black ctermfg=green cterm=bold
hi CursorLine ctermbg=black term=NONE cterm=NONE
hi LineNr ctermbg=black term=NONE ctermfg=gray cterm=NONE
hi SignColumn ctermbg=black term=NONE ctermfg=gray cterm=NONE
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


require('lspconfig').texlab.setup({
    cmd = {"texlab"},
    filetypes = {"tex", "bib"},
    settings = {
        latex = {
          build = {
            args = {  },
            executable = "latexmk",
            onSave = false
          },
          forwardSearch = {
            args = {},
            onSave = false
          },
          lint = {
            onChange = false
          },
        },
        texlab = {
            rootDirectory = nil,
            forwardSearch = {
                 -- executable = "evince_synctex.py",
                 -- args = {"-f", "%l", "%p", "gvim %f +%l"},
                 --
                 -- okular: either forward or backward, but not both.
                 -- executable = "okular",
                 -- args = {"--unique",
                 --         -- "--editor-cmd", "nvim --server " .. vim.v.servername .. " --remote-send \"%lG\"",
                 --         "file:%p#src:%l%f", },
                 executable = "synctex-katarakt.py",
                 args = {"--editor-command",
                         "nvim --server " .. vim.v.servername.. " --remote-expr "
                         .. "\"and(execute('e %{input}'), cursor(%{line}+1, %{column}+1))\"",
                         "--view-line", "%l",
                         "%f"},
            }
        }
    }
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = {'plaintex', 'tex'},
    callback = function()
        vim.wo.linebreak = true
        vim.keymap.set("n", ",v", ":TexlabForward<CR>", { silent = true })
        vim.keymap.set("n", ",b", ":w<CR>:TexlabBuild<CR>", { silent = false })
    end,
    desc = 'LaTeX specific settings'
})

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = false,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff'},
    lualine_c = {'filename'},
    lualine_x = {},
    lualine_y = {'encoding'},
    lualine_z = {'progress', 'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

return require('packer').startup(function()
  -- configuration of packer https://github.com/wbthomason/packer.nvim
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
      'nvim-lualine/lualine.nvim',
      requires = { 'kyazdani42/nvim-web-devicons', opt = true}
  }
  use 'morhetz/gruvbox'
  -- use({'jakewvincent/texmagic.nvim',
  --      config = function()
  --         require('texmagic').setup({
  --             -- Config goes here; leave blank for defaults
  --             engines = {
  --               pdflatex = {    -- This has the same name as a default engine but would
  --                               -- be preferred over the same-name default if defined
  --                   executable = "latexmk",
  --                   args = {
  --                       "%f"
  --                   },
  --                   isContinuous = false,
  --               },
  --             },
  --         })
  --      end
  -- })
  use({'neovim/nvim-lspconfig',
      config = function()
      end
  })
end)
