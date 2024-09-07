" Set leader key to space
let mapleader = " "

" Basic settings
set number                      " Show line numbers
set relativenumber              " Show relative line numbers
set tabstop=4                   " Number of spaces for a tab
set shiftwidth=4                " Number of spaces for each indentation level
set expandtab                   " Use spaces instead of tabs
set autoindent                  " Auto-indent new lines
set smartindent                 " Smart auto-indenting
set clipboard=unnamedplus       " Use system clipboard
set termguicolors               " Enable 24-bit RGB colors

" Enable syntax highlighting
syntax enable

" Initialize vim-plug
call plug#begin('~/.vim/plugged')

" Color scheme
Plug 'dracula/vim', {'as': 'dracula'} " Dracula color scheme

" Autocompletion plugins
Plug 'hrsh7th/nvim-cmp'         " Autocompletion plugin
Plug 'hrsh7th/cmp-nvim-lsp'     " LSP source for nvim-cmp
Plug 'hrsh7th/cmp-buffer'       " Buffer source for nvim-cmp
Plug 'hrsh7th/cmp-path'         " Path source for nvim-cmp
Plug 'hrsh7th/cmp-cmdline'      " Cmdline source for nvim-cmp

" LSP configurations
Plug 'neovim/nvim-lspconfig'    " Collection of configurations for built-in LSP client

" Optional - snippets support
Plug 'L3MON4D3/LuaSnip'         " Snippet engine
Plug 'saadparwaiz1/cmp_luasnip' " Snippet source for nvim-cmp

" Treesitter configuration
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Autopairs plugin
Plug 'windwp/nvim-autopairs'    " Automatically pairs brackets, quotes, etc.

" Status line
Plug 'nvim-lualine/lualine.nvim' " Status line plugin

" File explorer
Plug 'kyazdani42/nvim-tree.lua' " File explorer plugin

" Fuzzy finder and additional utilities
Plug 'nvim-telescope/telescope.nvim', {'tag': '0.1.1'} " Fuzzy finder
Plug 'nvim-lua/plenary.nvim'    " Required for many plugins
Plug 'tpope/vim-fugitive'       " Git integration

call plug#end()

" Set Dracula theme
colorscheme dracula

" Autocompletion setup
lua << EOF
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'cmdline' },
    { name = 'nvim_autopairs' },
  },
})
EOF
lua << EOF
require('lspconfig').pyright.setup{}
require('lspconfig').clangd.setup{
    cmd = { "clangd", "--background-index" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
}
EOF

lua << EOF
require('nvim-treesitter.configs').setup {
    
  ensure_installed = "all",
  highlight = {
    enable = true,           
  },
}

call packer#init()
packer#start('nvim-telescope/telescope.nvim', {'requires': {'nvim-lua/plenary.nvim'}})

EOF
lua << EOF
local npairs = require('nvim-autopairs')
local cmp = require('cmp')

npairs.setup{}

cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
EOF

lua << EOF
require('lualine').setup {
  options = {
    theme = 'dracula', 
    section_separators = '',
    component_separators = '',
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
}
EOF

lua << EOF
require('nvim-tree').setup {
  auto_close = true,
  view = {
    width = 30,
    side = 'left',
    auto_resize = true,
  },
}
EOF

nnoremap <leader>e :NvimTreeToggle<CR>

nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>fg :Telescope live_grep<CR>
nnoremap <leader>fb :Telescope buffers<CR>
nnoremap <leader>fh :Telescope help_tags<CR>

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

function! RunPython()
  execute 'w'
  execute '!python3 ' . shellescape(@%, 1)
endfunction

function! CompileRunC()
  execute 'w'
  let l:output_file = expand('%:r')
  execute '!gcc % -o ' . l:output_file . ' && ./' . l:output_file
endfunction
function! Terminal()
    execute 'terminal'
endfunction
function! CompileRunCpp()
  execute 'w'
  let l:output_file = expand('%:r')
  execute '!g++ % -o ' . l:output_file . ' && ./' . l:output_file
endfunction
function! SaveandEnd()
    execute 'wq'
endfunction
nnoremap <leader>r :call RunPython()<CR>

nnoremap <leader>c :call CompileRunC()<CR>
" Copy selected text to the clipboard
vnoremap <leader><leader>y "+y

" Paste from the clipboard

nnoremap <leader><leader>p :call CompileRunCpp()<CR>
nnoremap <leader><leader>q :call SaveandEnd()<CR>
nnoremap <leader><leader>t :call Terminal()<CR>
function! InstallPythonPackage(package)
  execute '!pip install ' . a:package
endfunction

command! -nargs=1 PipInstall call InstallPythonPackage(<f-args>)
