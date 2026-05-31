return {
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
