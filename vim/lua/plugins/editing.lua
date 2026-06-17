return {
  { "tpope/vim-commentary" },

  {
    "nvim-mini/mini.surround",
    version = false,
    opts = {},
  },

  {
    "tmsvg/pear-tree",
    init = function()
      vim.g.pear_tree_repeatable_expand = 1
      vim.g.pear_tree_smart_openers = 0
      vim.g.pear_tree_smart_closers = 0
      vim.g.pear_tree_smart_backspace = 0
    end,
  },

  {
    "mattn/emmet-vim",
    init = function()
      vim.g.user_emmet_expandabbr_key = "<leader><tab>"
    end,
  },

  { "glench/vim-jinja2-syntax" },

  {
    "andymass/vim-matchup",
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  {
    "rhysd/vim-clang-format",
    dependencies = { "kana/vim-operator-user" },
    init = function()
      vim.g["clang_format#code_style"] = "google"
      vim.g["clang_format#style_options"] = {
        IndentWidth = 4,
        AccessModifierOffset = -2,
      }
    end,
  },
}
