" ************** VUNDLE STUFF ********************
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Plugin 'tomasiser/vim-code-dark' " vscode theme
Plugin 'joshdick/onedark.vim' " Onedark theme
Plugin 'christoomey/vim-tmux-navigator' " Seamless vim/tmux pane navigation
Plugin 'tpope/vim-commentary' " Comments - use 'gcc' for line, 'gc' in visual or to comment out a target of a command
Plugin 'preservim/nerdtree' " Tree file explorer
Plugin 'ycm-core/YouCompleteMe' " Auto complete
Plugin 'ctrlpvim/ctrlp.vim' " Fuzzy file finder
Plugin 'sheerun/vim-polyglot' " Syntax highlighting
Plugin 'dense-analysis/ale' " Linter
Plugin 'rhysd/vim-clang-format' " Clang-format
Plugin 'kana/vim-operator-user' " Needed for clang-format
Plugin 'tmsvg/pear-tree' " Pair completion
Plugin 'Yggdroot/indentLine' " Indent guide

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

" sync clipboard register and default register
set clipboard^=unnamed

" Pair completion
let g:pear_tree_repeatable_expand = 1
let g:pear_tree_smart_openers = 0
let g:pear_tree_smart_closers = 0
let g:pear_tree_smart_backspace = 0

" Clang stuff
let g:clang_format#code_style = "google"
let g:clang_format#style_options = {
    \ "AccessModifierOffset" : -2}

" Linter stuff
let g:ale_sign_column_always = 1

" Color stuff
colorscheme onedark
syntax on
set colorcolumn=80

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

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

" ***** ADDED KEYBINDS ******

" remove TmuxNavigatePrevious
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
nnoremap <silent> <Nop> :TmuxNavigatePrevious<cr>

" NERDTree toggle
map <C-\> :NERDTreeToggle<CR>
" NERDTree on right
let g:NERDTreeWinPos = "right"

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
