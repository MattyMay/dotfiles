return {
  {
    "vimwiki/vimwiki",
    init = function()
      -- vimwiki reads these at load time, so they must be set in init.
      vim.g.vimwiki_list = {
        {
          path = vim.fn.expand("$HOME/vimwiki"),
          syntax = "markdown",
          ext = ".md",
          links_space_char = "_",
        },
      }
      vim.g.vimwiki_global_ext = 0
      vim.g.vimwiki_dir_link = "index"
      vim.g.vimwiki_autowriteall = 0
    end,
  },

  { "michal-h21/vimwiki-sync" },

  {
    "tools-life/taskwiki",
    init = function()
      vim.g.taskwiki_sort_orders = {
        U = "urgency-",
        D = "due+",
      }
    end,
  },
}
