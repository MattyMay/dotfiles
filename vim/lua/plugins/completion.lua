-- Insert a real <Tab> at line start or after whitespace (as coc's mapping did).
local function at_word()
  local col = vim.fn.col(".") - 1
  return col > 0 and vim.fn.getline("."):sub(col, col):match("%s") == nil
end

return {
  "saghen/blink.cmp",
  version = "1.*", -- release tags ship the prebuilt fuzzy matcher
  opts = {
    keymap = {
      preset = "none",
      ["<Tab>"] = {
        "select_next",
        "snippet_forward",
        function(cmp)
          if at_word() then
            cmp.show()
            return true
          end
        end,
        "fallback",
      },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    },
    completion = {
      -- Like coc's suggest.noselect: <CR> only accepts an item you picked.
      list = { selection = { preselect = false, auto_insert = true } },
      documentation = { auto_show = true },
    },
    signature = { enabled = true },
  },
}
