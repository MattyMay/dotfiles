return {
  {
    "christoomey/vim-tmux-navigator",
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    config = function()
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>", opts)
      vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>", opts)
      vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>", opts)
      vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>", opts)
    end,
  },

  {
    "preservim/nerdtree",
    init = function()
      vim.g.NERDTreeWinPos = "right"
    end,
    config = function()
      vim.keymap.set("n", "<C-\\>", ":NERDTreeToggle<CR>", { noremap = true, silent = true })
    end,
  },

  {
    "junegunn/fzf",
    build = "./install --all",
  },
  { "junegunn/fzf.vim" },
}
