" ************** VUNDLE STUFF ********************
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'ycm-core/YouCompleteMe' " Auto complete
Plugin 'ctrlpvim/ctrlp.vim' " Fuzzy file finder
Plugin 'sheerun/vim-polyglot' " Syntax highlighting
Plugin 'https://github.com/tomasiser/vim-code-dark' " vscode theme
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" ************************************************

" Color stuff
colorscheme codedark
syntax on

" C-style language auto-complete
let g:ycm_clangd_binary_path = "usr/bin/clangd"

" Whitespace
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab ai smartindent
set showbreak=↪\
set list
set listchars=tab:→\ ,nbsp:␣,space:·,extends:⟩,precedes:⟨
highlight SpecialKey ctermfg=239 guifg=DimGrey
let g:indentLine_char = '|' " indent level lines

" Cursor
let &t_SI = "\e[5 q"
let &t_EI = "\e[0 q"

augroup myCmds
au!
autocmd VimEnter * silent !echo -ne "\e[0 q"
augroup END

" Disable the default Vim startup message.
set shortmess+=I

set number " Show line numbers.
set relativenumber

" splits keybinds
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" More natural splits
set splitbelow
set splitright

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

" More intuitive backsapce  behavior
set backspace=indent,eol,start

set hidden

" Search stuff
set incsearch
set ignorecase
set smartcase
set hls

" Unbind some useless/annoying default key bindings.
nmap Q <Nop> " 'Q' in normal mode enters Ex mode. You almost never want this.

" Disable audible bell because it's annoying.
set noerrorbells visualbell t_vb=

set mouse+=a " necessary evil
