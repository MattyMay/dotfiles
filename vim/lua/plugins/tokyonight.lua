return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd("colorscheme tokyonight-moon")
    vim.cmd("highlight Comment cterm=italic gui=italic")
    vim.cmd("highlight SpecialKey ctermfg=239 guifg=DimGrey")
  end,
}
