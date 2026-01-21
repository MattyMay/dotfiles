local opt = vim.opt
local g = vim.g

-- Disable Vi compatibility
opt.compatible = false

-- Display
opt.number = true
opt.relativenumber = true
opt.colorcolumn = "80"
opt.showbreak = "↪ "
opt.list = true
opt.listchars = {
  tab = "→ ",
  nbsp = "␣",
  space = "·",
  extends = "⟩",
  precedes = "⟨"
}
opt.laststatus = 2

-- Colors and syntax
vim.cmd('colorscheme tokyonight-moon')
vim.cmd('syntax on')
vim.cmd('highlight Comment cterm=italic gui=italic')
vim.cmd('highlight SpecialKey ctermfg=239 guifg=DimGrey')

-- Indentation and whitespace
opt.tabstop = 4
opt.softtabstop = 0
opt.expandtab = true
opt.shiftwidth = 4
opt.smarttab = true
opt.autoindent = true
opt.smartindent = true

-- Folding
opt.foldmethod = "syntax"

-- Search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Backspace behavior
opt.backspace = { "indent", "eol", "start" }

-- Buffer management
opt.hidden = true

-- Backup and swap
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Update time
opt.updatetime = 300

-- Sign column
opt.signcolumn = "yes"

-- Disable bells
opt.errorbells = false
opt.visualbell = true
vim.cmd('set t_vb=')

-- Mouse
opt.mouse = "a"

-- Cursor configuration
vim.cmd([[
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[0 q"
  augroup myCmds
    au!
    autocmd VimEnter * silent !echo -ne "\e[0 q"
  augroup END
]])

-- Disable startup message
opt.shortmess:append("I")

-- Neovim specific
opt.showmode = false
opt.showcmd = false
opt.ruler = false

-- Termdebug
vim.cmd('packadd termdebug')
g.termdebug_wide = 1
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key (if needed)
vim.g.mapleader = " "

-- Disable Q (Ex mode)
map('n', 'Q', '<Nop>', opts)

-- Vim-tmux navigator
vim.g.tmux_navigator_no_mappings = 1
map('n', '<C-h>', ':TmuxNavigateLeft<CR>', opts)
map('n', '<C-j>', ':TmuxNavigateDown<CR>', opts)
map('n', '<C-k>', ':TmuxNavigateUp<CR>', opts)
map('n', '<C-l>', ':TmuxNavigateRight<CR>', opts)

-- NERDTree toggle
map('n', '<C-\\>', ':NERDTreeToggle<CR>', opts)
vim.g.NERDTreeWinPos = "right"

-- Copilot accept
map('i', '<leader><tab>', 'copilot#Accept("")', { expr = true, silent = true })
vim.g.copilot_no_tab_map = 1

-- Terminal mode escape
map('t', '<Esc>', '<C-\\><C-n>', opts)

-- Emmet
vim.g.user_emmet_expandabbr_key = '<tab>'
