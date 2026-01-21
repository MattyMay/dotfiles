-- Pear tree settings
vim.g.pear_tree_repeatable_expand = 1
vim.g.pear_tree_smart_openers = 0
vim.g.pear_tree_smart_closers = 0
vim.g.pear_tree_smart_backspace = 0

-- Clang format
vim.g['clang_format#code_style'] = "google"
vim.g['clang_format#style_options'] = {
  IndentWidth = 4,
  AccessModifierOffset = -2
}
