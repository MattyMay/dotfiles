-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
require("lazy").setup({
  -- GitHub Copilot
  { 'github/copilot.vim' },

  -- Indent guides
  { 
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
  },

  -- LSP and completion
  { 
    'neoclide/coc.nvim',
    branch = 'release',
  },

  -- Navigation and UI
  { 'christoomey/vim-tmux-navigator' },
  { 'tpope/vim-commentary' },
  { 'preservim/nerdtree' },
  
  -- Code formatting
  { 
    'rhysd/vim-clang-format',
    dependencies = { 'kana/vim-operator-user' }
  },

  -- Auto-pairing
  { 'tmsvg/pear-tree' },

  -- HTML/templating
  { 'mattn/emmet-vim' },
  { 'glench/vim-jinja2-syntax' },
  { 'andymass/vim-matchup' },

  -- Git integration
  { 'tpope/vim-fugitive' },

  -- Fuzzy finder
  { 
    'junegunn/fzf',
    build = './install --all'
  },
  { 'junegunn/fzf.vim' },

  -- Wiki/tasks
  { 'vimwiki/vimwiki' },
  { 'michal-h21/vimwiki-sync' },
  { 'tools-life/taskwiki' },

  -- Neovim specific
  { 'folke/todo-comments.nvim' },
  { 
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
  },
  { 'nvim-lualine/lualine.nvim' },
  { 
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
  },
})
