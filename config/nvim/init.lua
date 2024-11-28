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


noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj

" Disable linting via vim-ale:
let g:ale_enabled = 0

]],
true)

if vim.g.neovide then
    -- Put anything you want to happen only in Neovide here
    vim.o.guifont = "Source Code Pro:h12" -- text below applies for VimScript
    -- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
    vim.g.neovide_transparency = 0.95
    vim.g.neovide_background_color = "#9fbc0000"
    vim.g.neovide_cursor_animation_length = 0.08
    vim.g.neovide_cursor_trail_size = 0.0
end

function find_tex_main(source_file_path)
    --- try to find the main tex file for the given source file
    --- which is possible included in some other tex file.
    --- returns nil if no main file is found
    local command = {}
    -- table.insert(command, '--print-all')
    -- add all open files as candidates:
    table.insert(command, '--candidates')
    --- from https://codereview.stackexchange.com/a/282183
    for i, buf_hndl in ipairs(vim.api.nvim_list_bufs()) do
        table.insert(command, vim.api.nvim_buf_get_name(buf_hndl))
    end
    table.insert(command, '--')
    -- add the needle:
    table.insert(command, source_file_path)
    -- run the command:
    local Job = require'plenary.job'
    local command_path = vim.fn.stdpath("config") .. '/find-tex-main.py'

    -- alternatively: local output = vim.fn.system { 'echo', 'hi' }
    job_stdout = nil
    Job:new({
      command = command_path,
      args = command,
      -- cwd = '/usr/bin',
      -- env = { ['a'] = 'b' },
      on_stderr = function(error, data, j)
        print(data)
      end,
      on_stdout = function(error, more_job_stdout, j)
        job_stdout = job_stdout .. more_job_stdout
        -- print(job_stdout)
        -- vim.b[bufnr].main_tex_file = job_stdout
      end,
    }):sync()
    if job_stdout == '' then
        job_stdout = nil
    end
    return job_stdout
end

function find_tex_main_for_buffer(action_on_main_tex_file)
    bufnr = 0
    tex_file = vim.api.nvim_buf_get_name(bufnr)
    if vim.b[bufnr].main_tex_file == nil then
        vim.b[bufnr].main_tex_file = find_tex_main(tex_file)
        if input ~= nil then
            action_on_main_tex_file(vim.b[bufnr].main_tex_file)
        end
    end
    -- if still no main tex file has been found,
    -- then ask the user whether the buffer itself is the
    -- main tex file
    if vim.b[bufnr].main_tex_file == nil then
        vim.ui.input({
            prompt = "Enter the main tex file for " .. vim.fs.basename(tex_file) .. ": ",
            default = tex_file,
            completion = 'file',
        }, function(input)
            if input ~= nil and input ~= '' then
                vim.b[bufnr].main_tex_file = input
                action_on_main_tex_file(input)
            end
        end)
    end
end

function build_latex_buffer()
    find_tex_main_for_buffer(function(tex_file)
        if tex_file == nil or tex_file == '' then
            print('No main tex file found for ' .. vim.api.nvim_buf_get_name(0))
            return
        end
        local Job = require'plenary.job'

        -- alternatively: local output = vim.fn.system { 'echo', 'hi' }
        -- print('Compiling ' .. tex_file)
        Job:new({
          command = 'latexmk',
          args = {'-cd', tex_file},
          -- cwd = '/usr/bin',
          -- env = { ['a'] = 'b' },
          on_stderr = function(error, data, j)
            print(data)
          end,
          on_stdout = function(error, data, j)
            print(data)
          end,
          on_exit = function(error, exit_code, j)
            if exit_code ~= 0 then
                vim.schedule(function()
                    vim.cmd("messages")
                    -- vim.api.nvim_command('messages')
                end)
            end
          end,
        }):start() -- do not :sync() or the ui might block
    end)
end


vim.keymap.set("n", "<Space>", ":WhichKey ' '<CR>", { silent = true })
vim.keymap.set("n", ",", ":WhichKey ','<CR>", { silent = true })
vim.g.mapleader = " "
vim.o.timeout = true
vim.o.title = true
vim.o.timeoutlen = 100
-- vim.diagnostic.disable()
vim.diagnostic.config({
    update_in_insert = false,
    float = true,
    signs = false,
  })
-- buffers:
vim.keymap.set("n", "<C-o>", ":CtrlPBuffer<CR>")
vim.keymap.set("n", "<Leader>bn", ":bnext<CR>")
vim.keymap.set("n", "<Leader>bp", ":bprevious<CR>")
vim.keymap.set("n", "<Leader>bd", ":bdelete<CR>")
vim.keymap.set("n", "<Leader>bw", ":CtrlPBuffer<CR>")
vim.keymap.set("n", "<Leader>m", ":50messages<CR>")
-- git
vim.keymap.set("n", "<Leader>gc", ":Git commit -v<CR>")
vim.keymap.set("n", "<Leader>gC", ":Git commit -va<CR>")
vim.keymap.set("n", "<Leader>gP", ":Git push<CR>")
vim.keymap.set("n", "<Leader>gf", ":Git pull --rebase<CR>")
vim.keymap.set("n", "<Leader>gs", ":Git status<CR>")
vim.keymap.set("n", "<Leader>ga", ":Git add<CR>")
vim.keymap.set("n", "<Leader>gl", ":Git log --decorate=short<CR>")
vim.keymap.set("n", "<Leader>gS", ":terminal git show --word-diff=color<CR>")
vim.keymap.set("n", "<Leader>sn", ":Git log<CR>")

vim.api.nvim_create_autocmd('FileType', {
    pattern = {'plaintex', 'tex'},
    callback = function()
        vim.wo.linebreak = true
        vim.keymap.set("n", ",v", ":TexlabForward<CR>", { silent = true })
        -- vim.keymap.set("n", ",b", ":w<CR>:TexlabBuild<CR>", { silent = false })
        -- this does not work: vim.keymap.set("n", ",b", build_latex_buffer)
        vim.keymap.set("n", ",b", ":w<CR>:lua build_latex_buffer()<CR>", { silent = false })

        -- vim.keymap.set("n", ",w", ":w<CR>", { silent = false })
        vim.keymap.set("n", ",c", ":!latexmk -cd -c %:p<CR>", { silent = false })
        vim.o.sw = 2
        vim.o.ts = 2
    end,
    desc = 'LaTeX specific settings'
})

function setup_colorscheme()
  -- This function should be called in the colorscheme's config function
  vim.cmd.colorscheme('gruvbox')
  colorscheme_lua_code = [[
  set cursorline

  hi LineNr ctermbg=233 guibg=Black
  hi Normal ctermbg=NONE term=NONE guibg=NONE
  hi VertSplit ctermbg=NONE ctermfg=black cterm=NONE guibg=NONE
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
  ]]
  vim.api.nvim_exec(colorscheme_lua_code, true)

  if vim.g.neovide then
      vim.api.nvim_set_hl(0, "Normal", {bg='#181818'})
      vim.api.nvim_set_hl(0, "Cursor", {fg='#cc9900', bg='#339966'})
      vim.api.nvim_set_hl(0, "CursorReset", {fg='#9fbc00', bg='#008800'})
  end
end

function on_lsp_attach(ev)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- Buffer local mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local opts = { buffer = ev.buf }
  -- this would be nicer but produces an error message:
  -- vim.keymap.set('n', ',d', vim.lsp.buf.definition, { buffer = ev.buf, desc = "go to definition" })
  -- Warning: 'vim-which-key' does not support lua-callbacks
  vim.keymap.set('n', ',D', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.keymap.set('n', ',d', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.keymap.set('n', ',K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.keymap.set('n', ',i', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.keymap.set('n', ',s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
  vim.keymap.set('n', ',p', '<cmd>lua vim.lsp.buf.peek_definition()<CR>', opts)
  vim.keymap.set('n', ',r', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
  -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
  -- vim.keymap.set('n', '<space>wl', function()
  --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  -- end, opts)
  -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
  -- vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
  -- vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
  -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  -- vim.keymap.set('n', '<space>f', function()
  --   vim.lsp.buf.format { async = true }
  -- end, opts)
end

function spell_cycle()
  spelling_options = {
    '',
    'de',
    'en',
  }
  cur_value = ''
  if vim.opt.spell._value == true then
    cur_value = vim.opt.spelllang._value
  end
  -- print("cur val: " .. cur_value .. "x")
  -- print("cur val: " .. tostring(vim.opt.spelllang) .. "x")
  for idx, value in pairs(spelling_options) do
    if value == cur_value then
      new_value = spelling_options[idx % #(spelling_options) + 1] -- 1-based indices?
      print("Spelling Language: \"" .. tostring(new_value) .. "\"")
      if new_value ~= '' then
         vim.opt.spelllang = new_value
      end
      -- print(new_value)
      vim.opt.spell = new_value ~= ''
      break
    end
  end
end
vim.keymap.set("n", "<F7>", spell_cycle)

-- For debugging:
-- vim.lsp.set_log_level('debug')
-- and then run: tail -f ~/.local/state/nvim/lsp.log
function TexlabShowDependencyGraph()
    t = "called"
    -- vim.lsp.buf.execute_command({
    --   command = "texlab.showDependencyGraph",
    --   arguments = {},
    -- })
    function handler(err, result, ctx, config)
        print(result or err)
        t = result
    end
    cmd_and_args = {
      command = "texlab.showDependencyGraph",
      -- command = {"texlab.cleanArtifacts"},
      arguments = {},
      -- workDoneToken = {"some-arbitrary-text"},
    }
    res = vim.lsp.buf_request(0, 'workspace/executeCommand', cmd_and_args, handler)
end

return require('packer').startup(function()
  -- configuration of packer https://github.com/wbthomason/packer.nvim
  -- Packer can manage itself
  use 'nvim-lua/plenary.nvim'
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
  -- use({'hrsh7th/nvim-cmp',
  --   requires = { 'hrsh7th/cmp-vsnip' },
  --   requires = { 'hrsh7th/vim-vsnip' },
  --   config = function()
  --     local cmp = require('cmp')
  --     cmp.setup({
  --       snippet = {
  --         expand = function(args)
  --           vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
  --         end,
  --       },
  --       window = {
  --         completion = cmp.config.window.bordered(),
  --         documentation = cmp.config.window.bordered(),
  --       },
  --       mapping = cmp.mapping.preset.insert({
  --         ['<C-b>'] = cmp.mapping.scroll_docs(-4),
  --         ['<C-f>'] = cmp.mapping.scroll_docs(4),
  --         ['<C-Space>'] = cmp.mapping.complete(),
  --         ['<C-e>'] = cmp.mapping.abort(),
  --         ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  --       }),
  --       sources = cmp.config.sources({
  --         { name = 'nvim_lsp' },
  --       }, {
  --         { name = 'buffer' },
  --       })
  --     })
  --   end
  -- })
  use({'ellisonleao/gruvbox.nvim',
    -- until neovim 10 I've used 'morhetz/gruvbox', but then: https://github.com/morhetz/gruvbox/issues/459
    config = function()
      setup_colorscheme()
    end
  })
  use({'ctrlpvim/ctrlp.vim',
    config = function()
    end
  })
  use({'neovim/nvim-lspconfig',
      -- requires = { 'hrsh7th/cmp-nvim-lsp' },
      config = function()
        require('lspconfig').texlab.setup({
            on_attach = on_attach,
            cmd = {"texlab"},
            filetypes = {"tex", "bib"},
            -- now (2022-10-22) works without setting capabilities.
            -- capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
            init_options = { documentFormatting = true },
            settings = {
                -- latex = {
                -- },
                texlab = {
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
                    --rootDirectory = '/home/thorsten/git/papers/action-codes/icalp-talk/', -- cf https://github.com/latex-lsp/texlab/issues/106
                    rootDirectory = vim.fn.getcwd() .. '/', -- cf https://github.com/latex-lsp/texlab/issues/106
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
                         -- with some update '%{input}' etc had to be replaced with
                         -- '%%{input}'.. I don't know why -- 2023-06-14
                         args = {"--editor-command",
                                 "nvim --server " .. vim.v.servername.. " --remote-expr "
                                 .. "\"and(execute('e %%{input}'), cursor(%%{line}+1, %%{column}+1))\"",
                                 "--view-line", "%l",
                                 "%f"},
                    },
                    chktex = {
                      onEdit = false,
                      onOpenAndSave = false,
                    },
                }
            }
        })
        -- require('lspconfig').hls.setup({
        --   on_attach = on_attach,
        --   -- root_dir = vim.loop.cwd,
        --   -- capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
        --   settings = {
        --     rootMarkers = {".git/"}
        --   }
        -- })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = on_lsp_attach
      })
      end -- end of config-function
  })
  use 'tpope/vim-fugitive'
  use 'liuchengxu/vim-which-key'
  use 'jiangmiao/auto-pairs'
  --
  -- use({'tounaishouta/coq.vim',
  --   -- this coq plugin does not work well for me; it is unclear what the current goal is,
  --   -- and when opening a new line (via 'o'), the current line sometimes gets copied.
  --   config = function()
  --     vim.api.nvim_create_autocmd('FileType', {
  --         pattern = {'coq', 'v'},
  --         callback = function()
  --             vim.wo.linebreak = true
  --             vim.o.sw = 2
  --             vim.o.ts = 2
  --             vim.keymap.set("n", ",c", ":w<CR>:CoqRunToCursor<CR>", { silent = false })
  --             vim.keymap.set("n", ",w", ":w<CR>", { silent = false })
  --         end,
  --         desc = 'COQ specific settings'
  --     })
  --   end
  -- })
  -- use({'mrcjkb/haskell-tools.nvim',
  --   config = function()
  --       -- ~/.config/nvim/after/ftplugin/haskell.lua
  --       local ht = require('haskell-tools')
  --       local bufnr = vim.api.nvim_get_current_buf()
  --       local opts = { noremap = true, silent = true, buffer = bufnr, }
  --       -- haskell-language-server relies heavily on codeLenses,
  --       vim.keymap.set('n', '<space>a', '<Plug>HaskellHoverAction')
  --       -- so auto-refresh (see advanced configuration) is enabled by default
  --       vim.keymap.set('n', '<space>cl', vim.lsp.codelens.run, opts)
  --       -- Hoogle search for the type signature of the definition under the cursor
  --       vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
  --       -- Evaluate all code snippets
  --       vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, opts)
  --       -- Toggle a GHCi repl for the current package
  --       vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
  --       -- Toggle a GHCi repl for the current buffer
  --       vim.keymap.set('n', '<leader>rf', function()
  --         ht.repl.toggle(vim.api.nvim_buf_get_name(0))
  --       end, opts)
  --       vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)
  --   end
  -- })
end)
