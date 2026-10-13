-- Language servers, enabled with nvim's built-in client. Names are
-- nvim-lspconfig config names; mason installs the binaries.
local servers = {
  "bashls",
  "clangd",
  "cssls",
  "eslint",
  "html",
  "jsonls",
  "lua_ls",
  "pyright",
  "vimls",
  "vtsls",
  "vue_ls",
}

-- Non-LSP tools for mason to install (mason puts them on PATH for conform).
local tools = { "prettier" }

-- Vue 2 projects keep the Volar 2.2.8 pair coc-volar ran, via the
-- vue_ls_vue2/vtsls_vue2 configs; Vue 3 projects get mason's current
-- vue_ls/vtsls. mason holds one version per package, so npm installs these.
local vue2 = {
  dir = vim.fn.stdpath("data") .. "/vue2-language-server",
  packages = {
    ["@vue/language-server"] = "2.2.8",
    ["@vue/typescript-plugin"] = "2.2.8",
    ["typescript"] = "5.9.3", -- tsdk for the server; matches vtsls's bundled TS
  },
}
vue2.cmd = vue2.dir .. "/node_modules/.bin/vue-language-server"

local function read_json(path)
  local ok, data = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)
  return ok and type(data) == "table" and data or {}
end

local function ensure_vue2_server()
  local installed = vim.tbl_get(read_json(vue2.dir .. "/package.json"), "dependencies") or {}
  if vim.deep_equal(installed, vue2.packages) or vim.fn.executable("npm") == 0 then
    return
  end
  local args = { "npm", "install", "--prefix", vue2.dir, "--save-exact", "--no-fund", "--no-audit" }
  for name, version in pairs(vue2.packages) do
    table.insert(args, name .. "@" .. version)
  end
  vim.notify("Installing the Vue 2 language server...")
  vim.system(args, {}, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify("Vue 2 language server installed; reopen .vue buffers to start it")
      else
        vim.notify("Vue 2 language server install failed:\n" .. result.stderr, vim.log.levels.ERROR)
      end
    end)
  end)
end

-- Whether a buffer is in a Vue 2 project, judged by the nearest package.json:
-- the installed vue version, else the declared range.
local vue2_roots = {}
local function is_vue2(bufnr)
  local root = vim.fs.root(bufnr, "package.json")
  if not root then
    return false
  end
  if vue2_roots[root] == nil then
    local version = read_json(root .. "/node_modules/vue/package.json").version
    if not version then
      local pkg = read_json(root .. "/package.json")
      version = vim.tbl_get(pkg, "dependencies", "vue") or vim.tbl_get(pkg, "devDependencies", "vue") or ""
    end
    vue2_roots[root] = version:match("^%D*(%d+)") == "2"
  end
  return vue2_roots[root]
end

local function not_vue2(bufnr)
  return not is_vue2(bufnr)
end

local function vue2_ready(bufnr)
  return is_vue2(bufnr) and vim.fn.executable(vue2.cmd) == 1
end

-- Wraps a root_dir so the config only attaches where `pred(bufnr)` holds.
local function only_if(pred, root_dir)
  return function(bufnr, on_dir)
    if pred(bufnr) then
      root_dir(bufnr, on_dir)
    end
  end
end

local function package_root(bufnr, on_dir)
  local root = vim.fs.root(bufnr, "package.json")
  if root then
    on_dir(root)
  end
end

local function vtsls_vue_plugin(location)
  return {
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
    settings = {
      vtsls = {
        tsserver = {
          globalPlugins = {
            {
              name = "@vue/typescript-plugin",
              location = location,
              languages = { "vue" },
              configNamespace = "typescript",
            },
          },
        },
      },
    },
  }
end

-- Runs `fn(range)` over the motion that follows, so `<leader>fip` and
-- `<leader>aap` work like coc's *-selected operators did.
local function operator(fn)
  return function()
    _G.lsp_operatorfunc = function()
      local s = vim.api.nvim_buf_get_mark(0, "[")
      local e = vim.api.nvim_buf_get_mark(0, "]")
      fn({ start = s, ["end"] = { e[1], #vim.fn.getline(e[1]) } })
    end
    vim.o.operatorfunc = "v:lua.lsp_operatorfunc"
    return "g@"
  end
end

local function format(opts)
  require("conform").format(vim.tbl_extend("force", { lsp_format = "fallback" }, opts or {}))
end

-- Buffer-local maps, so non-LSP buffers keep the builtin gi/K/etc.
local function on_attach(args)
  local buf = args.buf
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = buf, silent = true }, opts or {}))
  end

  -- GoTo code navigation (nowait: don't stall on the builtin grr/gri/...)
  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gy", vim.lsp.buf.type_definition)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", "gr", vim.lsp.buf.references, { nowait = true })

  -- Show documentation (vim/help files keep K -> :help)
  if not vim.tbl_contains({ "vim", "help" }, vim.bo[buf].filetype) then
    map("n", "K", vim.lsp.buf.hover)
  end

  -- Rename
  map("n", "<leader>rn", vim.lsp.buf.rename)

  -- Format
  map("x", "<leader>f", format)
  map("n", "<leader>f", operator(function(range) format({ range = range }) end), { expr = true })

  -- Code actions
  map("x", "<leader>a", vim.lsp.buf.code_action)
  map("n", "<leader>a", operator(function(range) vim.lsp.buf.code_action({ range = range }) end), { expr = true })
  map("n", "<leader>ac", vim.lsp.buf.code_action)
  map("n", "<leader>qf", function()
    vim.lsp.buf.code_action({ context = { only = { "quickfix" } }, apply = true })
  end)
  map("n", "<leader>cl", vim.lsp.codelens.run)

  -- Selection ranges
  map("n", "<C-s>", function()
    vim.cmd("normal! v")
    vim.lsp.buf.selection_range(1)
  end)
  map("x", "<C-s>", function() vim.lsp.buf.selection_range(vim.v.count1) end)

  -- Highlight symbol under cursor
  if client and client:supports_method("textDocument/documentHighlight") then
    local group = vim.api.nvim_create_augroup("lsp_highlight_" .. buf, { clear = true })
    vim.api.nvim_create_autocmd("CursorHold", { group = group, buffer = buf, callback = vim.lsp.buf.document_highlight })
    vim.api.nvim_create_autocmd("CursorMoved", { group = group, buffer = buf, callback = vim.lsp.buf.clear_references })
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      -- Install missing servers and tools on startup, but not in headless runs
      -- (tests, CI), which would quit mid-download.
      local interactive = #vim.api.nvim_list_uis() > 0
      require("mason-lspconfig").setup({
        ensure_installed = interactive and servers or {},
        automatic_enable = false,
      })
      if interactive then
        local registry = require("mason-registry")
        registry.refresh(function()
          for _, tool in ipairs(tools) do
            local pkg = registry.get_package(tool)
            if not pkg:is_installed() then
              pkg:install()
            end
          end
        end)
      end

      vim.lsp.config("clangd", {
        cmd = { "clangd", "--query-driver=/usr/bin/g++", "--background-index" },
      })

      -- Vue: vtsls hosts @vue/typescript-plugin for script blocks. Volar 3's
      -- vue_ls forwards its TypeScript requests to vtsls; Volar 2 talks to the
      -- plugin over a named pipe instead.
      local vtsls_defaults = vim.lsp.config.vtsls
      vim.lsp.config("vtsls", vim.tbl_extend("force", vtsls_vue_plugin(vim.fn.stdpath("data")
        .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"), {
        root_dir = only_if(not_vue2, vtsls_defaults.root_dir),
      }))
      vim.lsp.config("vue_ls", {
        root_dir = only_if(not_vue2, package_root),
        settings = { vue = { hover = { rich = true } } },
      })

      vim.lsp.config("vtsls_vue2", vim.tbl_extend("force", vtsls_defaults, vtsls_vue_plugin(vue2.dir), {
        root_dir = only_if(vue2_ready, vtsls_defaults.root_dir),
      }))
      vim.lsp.config("vue_ls_vue2", {
        cmd = { vue2.cmd, "--stdio" },
        filetypes = { "vue" },
        root_dir = only_if(vue2_ready, package_root),
        init_options = {
          typescript = { tsdk = vue2.dir .. "/node_modules/typescript/lib" },
          vue = { hybridMode = true },
        },
      })
      if interactive then
        ensure_vue2_server()
      end

      vim.lsp.enable(servers)
      vim.lsp.enable({ "vtsls_vue2", "vue_ls_vue2" })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
        callback = on_attach,
      })

      -- Diagnostics
      vim.keymap.set("n", "[g", function() vim.diagnostic.jump({ count = -1, float = true }) end, { silent = true })
      vim.keymap.set("n", "]g", function() vim.diagnostic.jump({ count = 1, float = true }) end, { silent = true })

      -- Commands
      vim.api.nvim_create_user_command("Format", function() format() end, { bar = true })
      vim.api.nvim_create_user_command("Fold", function()
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
        vim.cmd("normal! zM")
      end, { bar = true })
      vim.api.nvim_create_user_command("OR", function()
        vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
      end, { bar = true })
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = function()
      local prettier = {}
      for _, ft in ipairs({
        "css", "graphql", "html", "javascript", "javascriptreact", "json", "jsonc",
        "less", "markdown", "scss", "typescript", "typescriptreact", "vue", "yaml",
      }) do
        prettier[ft] = { "prettier" }
      end
      return { formatters_by_ft = prettier }
    end,
    config = function(_, opts)
      require("conform").setup(opts)
      vim.api.nvim_create_user_command("Prettier", function()
        require("conform").format({ formatters = { "prettier" } })
      end, { bar = true })
    end,
  },
}
