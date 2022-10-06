-- vim: sw=2 ts=2
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

set ignorecase smartcase


" highlight whitespaces and trailing spaces
set list
set listchars=tab:>\ ,trail:·,nbsp:_
"set listchars=tab:▸\ ,eol:¬

set fillchars+=vert:│

" menu and completion -> bash-like
set wildmenu
set wildmode=longest,list
set wildignorecase

set breakindent
set showbreak=..

" always use the X11 clipboard
set clipboard=unnamedplus
set showcmd

filetype indent off

autocmd FileType text syn match   plainTextComment "#.*$"
autocmd FileType text hi def link plainTextComment Comment


set cursorline
colorscheme gruvbox

hi LineNr ctermbg=233 guibg=Black
hi Normal ctermbg=NONE term=NONE
hi VertSplit ctermbg=NONE ctermfg=black cterm=NONE
hi Visual ctermbg=black cterm=None
hi Spellbad ctermbg=red cterm=None
hi StatusLineNC ctermbg=black ctermfg=white cterm=NONE
hi StatusLine ctermbg=black ctermfg=green cterm=bold
hi LineNr ctermbg=black term=NONE ctermfg=gray cterm=NONE
hi SignColumn ctermbg=black term=NONE ctermfg=gray cterm=NONE
hi CursorLineNr ctermbg=black term=NONE ctermfg=green cterm=bold
hi CursorLine ctermbg=black term=NONE cterm=NONE
hi CursorLine ctermbg=233 term=NONE cterm=NONE
hi CursorLineNr ctermbg=233 term=NONE ctermfg=green cterm=bold

noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj

]],
true)

vim.keymap.set("n", "<Space>", ":WhichKey ' '<CR>", { silent = true })
vim.keymap.set("n", ",", ":WhichKey ','<CR>", { silent = true })
vim.g.mapleader = " "
vim.o.timeout = true
vim.o.title = true
vim.o.timeoutlen = 100
-- buffers:
vim.keymap.set("n", "<C-o>", ":CtrlPBuffer<CR>")
vim.keymap.set("n", "<Leader>bn", ":bnext<CR>")
vim.keymap.set("n", "<Leader>bp", ":bprevious<CR>")
vim.keymap.set("n", "<Leader>bd", ":bdelete<CR>")
vim.keymap.set("n", "<Leader>bw", ":CtrlPBuffer<CR>")
-- git
vim.keymap.set("n", "<Leader>gc", ":Git commit -v<CR>")
vim.keymap.set("n", "<Leader>gC", ":Git commit -va<CR>")
vim.keymap.set("n", "<Leader>gP", ":Git push<CR>")
vim.keymap.set("n", "<Leader>gf", ":Git pull --rebase<CR>")
vim.keymap.set("n", "<Leader>gs", ":Git status<CR>")
vim.keymap.set("n", "<Leader>ga", ":Git add<CR>")
vim.keymap.set("n", "<Leader>gl", ":Git log<CR>")
vim.keymap.set("n", "<Leader>gS", ":terminal git show --word-diff=color<CR>")
vim.keymap.set("n", "<Leader>sn", ":Git log<CR>")

vim.api.nvim_create_autocmd('FileType', {
    pattern = {'plaintex', 'tex'},
    callback = function()
        vim.wo.linebreak = true
        vim.keymap.set("n", ",v", ":TexlabForward<CR>", { silent = true })
        vim.keymap.set("n", ",b", ":w<CR>:TexlabBuild<CR>", { silent = false })
        vim.keymap.set("n", ",c", ":!latexmk -cd -c %:p<CR>", { silent = false })
        vim.o.sw = 2
        vim.o.ts = 2
    end,
    desc = 'LaTeX specific settings'
})

return require('packer').startup(function()
  -- configuration of packer https://github.com/wbthomason/packer.nvim
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
      'nvim-lualine/lualine.nvim',
      requires = { 'kyazdani42/nvim-web-devicons', opt = true },
      config = function()
        require('lualine').setup {
          options = {
            icons_enabled = true,
            theme = 'onedark',
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
      end
  }
  -- use {
  --   'lervag/vimtex'
  -- }
  use({'hrsh7th/nvim-cmp',
    requires = { 'hrsh7th/cmp-vsnip' },
    requires = { 'hrsh7th/vim-vsnip' },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        }, {
          { name = 'buffer' },
        })
      })
    end
  })
  use 'morhetz/gruvbox'
  use({'ctrlpvim/ctrlp.vim',
    config = function()
    end
  })
  use({'neovim/nvim-lspconfig',
      requires = { 'hrsh7th/cmp-nvim-lsp' },
      config = function()
        require('lspconfig').texlab.setup({
            on_attach = on_attach,
            cmd = {"texlab"},
            filetypes = {"tex", "bib"},
            capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
            init_options = { documentFormatting = true },
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
                    -- latexFormatter = 'latexindent',
                    -- latexindent = {
                    --   ['local'] = '/dev/null', -- local is a reserved keyword
                    --   modifyLineBreaks = false,
                    -- },
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
        -- require('lspconfig').hls.setup({
        --   on_attach = on_attach,
        --   root_dir = vim.loop.cwd,
        --   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
        --   settings = {
        --     rootMarkers = {"./git/"}
        --   }
        -- })
      end
  })
  use 'tpope/vim-fugitive'
  use 'liuchengxu/vim-which-key'
end)
