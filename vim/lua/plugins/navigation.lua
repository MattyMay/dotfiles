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
    -- --bin only: --all rewrites ~/.fzf.bash and rc files; bash setup lives in fzf_config
    build = "./install --bin",
  },

  {
    "ibhagwan/fzf-lua",
    dependencies = { "junegunn/fzf" },
    opts = function()
      -- fzf's install script leaves the binary in the plugin dir, not on PATH.
      local bin = require("lazy.core.config").plugins.fzf.dir .. "/bin/fzf"
      return {
        fzf_bin = vim.fn.executable("fzf") == 1 and "fzf" or bin,
      }
    end,
    config = function(_, opts)
      require("fzf-lua").setup(opts)
      -- fzf.vim's commands (:Files, :Rg, :Buffers, ...) backed by fzf-lua. Just the
      -- commands from the fzf-vim profile, not its window/preview styling.
      require("fzf-lua.profiles.fzf-vim").fn_load()
      local map_opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<space>a", "<cmd>FzfLua diagnostics_workspace<CR>", map_opts)
      vim.keymap.set("n", "<space>e", "<cmd>Mason<CR>", map_opts)
      vim.keymap.set("n", "<space>c", "<cmd>FzfLua commands<CR>", map_opts)
      vim.keymap.set("n", "<space>o", "<cmd>FzfLua lsp_document_symbols<CR>", map_opts)
      vim.keymap.set("n", "<space>s", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", map_opts)
      vim.keymap.set("n", "<space>p", "<cmd>FzfLua resume<CR>", map_opts)
      -- Step through a list sent to quickfix (alt-q in any picker).
      vim.keymap.set("n", "<space>j", "<cmd>cnext<CR>", map_opts)
      vim.keymap.set("n", "<space>k", "<cmd>cprev<CR>", map_opts)
    end,
  },
}
