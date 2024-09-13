let mapleader=","

call plug#begin('~/vim/plugged')
" below are some vim plugins for demonstration purpose.
" add the plugin you want to use here.
" Plug 'joshdick/onedark.vim'
" Plug 'iCyMind/NeoSolarized'
" 
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'sheerun/vim-polyglot'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()

" Set spaces for tabs
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Set line numbers
set number
set relativenumber

" syntax and indent
" syntax on
set cursorline


" redraw ony when we need to
set lazyredraw

" turnoff search highlight
nnoremap <leader><space> :nohlsearch<CR>


" folding
set foldenable
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
" space open/closes folds
nnoremap <space> za
set foldmethod=indent   " fold based on indent level

" move vertically by visual line
nnoremap j gj
nnoremap k gk

" edit vimrc/zshrc and load vimrc bindings
nnoremap <leader>rc :source $MYVIMRC<CR>
nnoremap <leader>oc :vsp $MYVIMRC<CR>

" NERDTREE
nnoremap <C-space> :NERDTreeToggle<CR>
nnoremap <leader>z :NERDTreeToggle<CR>
nnoremap <leader>q :NERDTreeRefreshRoot<CR>

" FZF
nnoremap <leader>ff :FZF<CR>
nnoremap <leader>fc :Rg<CR>
let $FZF_DEFAULT_OPTS = '--bind "ctrl-j:down,ctrl-k:up,alt-j:preview-down,alt-k:preview-up"'

" map c-space to auto suggest
inoremap <C-@> <C-n>

imap <C-BS> <C-W>

" show 7 lines
set so=7

set paste

set mouse=a
set autoindent

set colorcolumn=101
set scrolloff=5

set autoread

nnoremap <leader>ff :Files<CR>
nnoremap <leader>rr :Rg<CR>

set rtp^="/home/an0ne/.opam/chipate/share/ocp-indent/vim"

nnoremap Y yy

set hlsearch
