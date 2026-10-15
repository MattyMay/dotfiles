-- nvim-treesitter's main branch only installs parsers and queries; highlighting
-- and indent are switched on per buffer below. Building parsers needs the
-- tree-sitter CLI (0.26.1+) and a C compiler.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "dockerfile",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
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
    },
    config = function(_, opts)
      local ts = require("nvim-treesitter")

      -- Install in the background on interactive starts only; headless runs
      -- (tests, CI) would quit mid-build. tests/run.sh installs them itself.
      local interactive = #vim.api.nvim_list_uis() > 0
      if interactive then
        ts.install(opts.ensure_installed)
      end

      local function enable(buf, lang)
        if not pcall(vim.treesitter.start, buf, lang) then
          return
        end
        if vim.treesitter.query.get(lang, "indents") then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      local available = nil
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end
          if vim.treesitter.language.add(lang) then
            enable(args.buf, lang)
            return
          end
          -- Missing parser: install it if nvim-treesitter knows it (what
          -- master's auto_install did), then enable once it's built.
          available = available or ts.get_available()
          if interactive and vim.tbl_contains(available, lang) then
            ts.install(lang):await(vim.schedule_wrap(function()
              if vim.api.nvim_buf_is_valid(args.buf) then
                enable(args.buf, lang)
              end
            end))
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    opts = { select = { lookahead = true } },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)
      for lhs, capture in pairs({
        ["if"] = "@function.inner",
        ["af"] = "@function.outer",
        ["ic"] = "@class.inner",
        ["ac"] = "@class.outer",
      }) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          require("nvim-treesitter-textobjects.select").select_textobject(capture, "textobjects")
        end)
      end
    end,
  },
}
