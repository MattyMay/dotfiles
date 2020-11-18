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
Plugin 'christoomey/vim-tmux-navigator' " Seamless vim/tmux pane navigation
Plugin 'tpope/vim-commentary' " Comments - use 'gcc' for line, 'gc' in visual or to comment out a target of a command
Plugin 'preservim/nerdtree' " Tree file explorer
Plugin 'ctrlpvim/ctrlp.vim' " Fuzzy file finder
Plugin 'dense-analysis/ale' " Linter
Plugin 'rhysd/vim-clang-format' " Clang-format
Plugin 'kana/vim-operator-user' " Needed for clang-format
Plugin 'tmsvg/pear-tree' " Pair completion

" Coc
Plugin 'neoclide/coc.nvim' " Auto complete / LSP
Plugin 'neoclide/coc-json'
Plugin 'neoclide/coc-git'
Plugin 'clangd/coc-clangd'
Plugin 'neoclide/coc-css'
Plugin 'neoclide/coc-html'
Plugin 'neoclide/coc-java'
Plugin 'neoclide/coc-python'
Plugin 'josa42/coc-sh'

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

" Linter stuff
let g:ale_sign_column_always = 1

" ************** COC AUTOCOMPLETE *****************
" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
" Note coc#float#scroll works on neovim >= 0.4.0 or vim >= 8.2.0750
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scrll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

" NeoVim-only mapping for visual mode scroll
" Useful on signatureHelp after jump placeholder of snippet expansion
if has('nvim')
  vnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
  vnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>o


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
set clipboard^=unnamed

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


" Disable audible bell because it's annoying.
set noerrorbells visualbell t_vb=

set mouse+=a " necessary evil
