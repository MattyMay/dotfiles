" ************** VUNDLE STUFF ********************
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" colors, themes, etc
Plugin 'itchyny/lightline.vim' " fancy status bar
Plugin 'joshdick/onedark.vim' " Onedark theme
Plugin 'Yggdroot/indentLine' " Indent guide


" Helper functionality
Plugin 'neoclide/coc.nvim' " Auto complete / LSP
Plugin 'christoomey/vim-tmux-navigator' " Seamless vim/tmux pane navigation
Plugin 'tpope/vim-commentary' " Comments - use 'gcc' for line, 'gc' in visual or to comment out a target of a command
Plugin 'preservim/nerdtree' " Tree file explorer
Plugin 'ctrlpvim/ctrlp.vim' " Fuzzy file finder
Plugin 'rhysd/vim-clang-format' " Clang-format
Plugin 'kana/vim-operator-user' " Needed for clang-format
Plugin 'tmsvg/pear-tree' " Pair completion
Plugin 'mattn/emmet-vim' " Emmet html completion functionality

" Neovim specific plugins
if has('nvim')
    Plugin 'nvim-treesitter/nvim-treesitter' " Better highlighting

" Vim specific plugins
else
    Plugin 'sheerun/vim-polyglot' " Syntax highlighting

endif

call vundle#end()            " required
filetype plugin indent on    " required

" **************** VIM / NVIM *********************
" Neovim specific settings
if has('nvim')
    set noshowcmd noruler " can slow things down in nvim
else
    " C-style language auto-complete
    let g:ycm_clangd_binary_path = "usr/bin/clangd"
endif

" **************** PAIR COMPLETION ****************
let g:pear_tree_repeatable_expand = 1
let g:pear_tree_smart_openers = 0
let g:pear_tree_smart_closers = 0
let g:pear_tree_smart_backspace = 0

" Clang stuff - default format style
let g:clang_format#code_style = "google"
let g:clang_format#style_options = {
    \ "IndentWidth" : 4,
    \ "AccessModifierOffset" : -2}

" **************** COC STUFF **********************
" Includes LSPs, keybinds, general config/necessities
source ~/.coc-vimrc

" ************** COLOR, SYNTAX ********************
colorscheme onedark
syntax on
highlight Comment cterm=italic gui=italic
set colorcolumn=80
let g:lightline = {
  \ 'colorscheme': 'onedark',
  \ }
if exists('+termguicolors') " fix weird colors in tmux
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif


" *************** WHITE SPACE **********************
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab ai smartindent
set showbreak=↪\
set list
set listchars=tab:→\ ,nbsp:␣,space:·,extends:⟩,precedes:⟨
highlight SpecialKey ctermfg=239 guifg=DimGrey
let g:indentLine_char = '|' " indent level lines

" *************** KEYBINDS *************************
" remove <C-\> for vim/tmux pane nav
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
nnoremap <silent> <nop> :TmuxNavigatePrevious<cr>
" NERDTree toggle
map <C-\> :NERDTreeToggle<CR>
" NERDTree on right
let g:NERDTreeWinPos = "right"
" Unbind some useless/annoying default key bindings.
nmap Q <Nop> " 'Q' in normal mode enters Ex mode. You almost never want this.

" ****************** MISC **************************
" Folding
set foldmethod=syntax

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
" sync clipboard register and default register
set clipboard+=unnamedplus

" More natural splits
set splitbelow
set splitright

" termdebug stuff
packadd termdebug
let g:termdebug_wide=1
tnoremap <Esc> <C-\><C-n>

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


" Disable audible bell because it's annoying.
set noerrorbells visualbell t_vb=

set mouse+=a " necessary evil
