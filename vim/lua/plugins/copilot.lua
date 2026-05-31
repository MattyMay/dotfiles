return {
  "github/copilot.vim",
  init = function()
    -- Must be set before the plugin loads so it doesn't map <Tab> itself.
    vim.g.copilot_no_tab_map = 1
  end,
  config = function()
    vim.keymap.set("i", "<leader><tab>", 'copilot#Accept("")', { expr = true, silent = true })
  end,
}
