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

-- NOTE: keymaps live in keymaps.lua (loaded separately from init.lua)
