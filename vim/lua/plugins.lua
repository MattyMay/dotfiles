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

require("lazy").setup({
  { "github/copilot.vim" },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
  },

  {
    "neoclide/coc.nvim",
    branch = "release",
  },

  { "christoomey/vim-tmux-navigator" },
  { "tpope/vim-commentary" },
  { "preservim/nerdtree" },

  {
    "rhysd/vim-clang-format",
    dependencies = { "kana/vim-operator-user" },
  },

  { "tmsvg/pear-tree" },
  { "mattn/emmet-vim" },
  { "glench/vim-jinja2-syntax" },

  {
    "andymass/vim-matchup",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  { "tpope/vim-fugitive" },

  {
    "junegunn/fzf",
    build = "./install --all",
  },
  { "junegunn/fzf.vim" },

  { "vimwiki/vimwiki" },
  { "michal-h21/vimwiki-sync" },
  { "tools-life/taskwiki" },

  { "folke/todo-comments.nvim" },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },
  { "nvim-lualine/lualine.nvim" },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter.configs").setup({
        sync_install = false,
        auto_install = true,
        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "css",
          "dockerfile",
          "html",
          "javascript",
          "json",
          "jsonc",
          "lua",
          "markdown",
          "python",
          "query",
          "rust",
          "scss",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "vue",
          "yaml",
        },
        highlight = {
          enable = true,
          disable = {},
        },
        indent = {
          enable = true,
        },
      })
    end,
  }
})
