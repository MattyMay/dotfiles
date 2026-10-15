-- Verifies that the Neovim config loads and applies as expected, after plugins
-- have been installed. Run with: nvim --headless -c 'luafile verify.lua'
-- Exits non-zero (via :cq) if any check fails.

-- Write + flush each line immediately so checks stream one by one, even when
-- stdout is buffered (CI logs, pipes), and the last line is never swallowed by :qa.
local function emit(line)
  io.stdout:write(line .. "\n")
  io.stdout:flush()
end

local failures = 0
local function check(name, cond)
  if cond then
    emit("ok   - " .. name)
  else
    emit("FAIL - " .. name)
    failures = failures + 1
  end
end

local function has_map(mode, lhs)
  return vim.fn.maparg(lhs, mode) ~= ""
end

-- ── Plugins are present (lazy loaded its specs) ──────────────────────────────
local ok_lazy, lazy_config = pcall(require, "lazy.core.config")
check("lazy.nvim is loaded", ok_lazy)
local plugins = ok_lazy and lazy_config.plugins or {}
for _, name in ipairs({
  "nvim-lspconfig",
  "mason.nvim",
  "mason-lspconfig.nvim",
  "blink.cmp",
  "conform.nvim",
  "gitsigns.nvim",
  "fzf-lua",
  "nvim-treesitter-textobjects",
  "tokyonight.nvim",
  "nvim-treesitter",
  "lualine.nvim",
  "indent-blankline.nvim",
  "nerdtree",
  "vim-tmux-navigator",
  "vimwiki",
  "taskwiki",
  "emmet-vim",
  "vim-matchup",
  "vim-clang-format",
  "vim-fugitive",
  "fzf.vim",
}) do
  check("plugin spec present: " .. name, plugins[name] ~= nil)
end

-- ── Colorscheme and custom highlights (plugins/tokyonight.lua) ───────────────
check("colorscheme is tokyonight-moon", vim.g.colors_name == "tokyonight-moon")
check("Comment highlight is italic", vim.api.nvim_get_hl(0, { name = "Comment" }).italic == true)

-- ── Plugin g: vars set via init() (must apply before each plugin loads) ──────
check("tmux_navigator_no_mappings = 1", vim.g.tmux_navigator_no_mappings == 1)
check("emmet expand key is <leader><tab>", vim.g.user_emmet_expandabbr_key == "<leader><tab>")
check("NERDTreeWinPos is right", vim.g.NERDTreeWinPos == "right")
check("vimwiki_list configured", type(vim.g.vimwiki_list) == "table" and #vim.g.vimwiki_list == 1)
check("taskwiki_sort_orders configured", type(vim.g.taskwiki_sort_orders) == "table")
check("matchup offscreen popup configured", type(vim.g.matchup_matchparen_offscreen) == "table")
check("clang-format code_style is google", vim.g["clang_format#code_style"] == "google")

-- ── Core options (settings.lua) ──────────────────────────────────────────────
check("expandtab", vim.o.expandtab == true)
check("shiftwidth = 4", vim.o.shiftwidth == 4)
check("tabstop = 4", vim.o.tabstop == 4)
check("number", vim.o.number == true)
check("relativenumber", vim.o.relativenumber == true)
check("ignorecase", vim.o.ignorecase == true)
check("smartcase", vim.o.smartcase == true)
check("updatetime = 300", vim.o.updatetime == 300)
check("signcolumn = yes", vim.o.signcolumn == "yes")
check("mouse = a", vim.o.mouse == "a")
check("swapfile disabled", vim.o.swapfile == false)

-- ── Keymaps ──────────────────────────────────────────────────────────────────
check("Q is disabled", has_map("n", "Q"))
check("<C-h> tmux navigation", has_map("n", "<C-h>"))
check("<C-\\> NERDTree toggle", has_map("n", "<C-\\>"))
check("]g next diagnostic", has_map("n", "]g"))
check("<space>o document symbols (fzf-lua)", has_map("n", "<space>o"))

-- ── Language servers (plugins/lsp.lua) ───────────────────────────────────────
for _, name in ipairs({
  "bashls", "clangd", "cssls", "eslint", "html", "jsonls",
  "lua_ls", "pyright", "vimls", "vtsls", "vue_ls",
}) do
  check("LSP enabled: " .. name, vim.lsp.is_enabled(name))
end
local vue_ls = vim.lsp.config.vue_ls or {}
check("vue_ls rich hover", vim.tbl_get(vue_ls, "settings", "vue", "hover", "rich") == true)
-- Rich hover's HTML table, as Volar 3 builds it, becomes markdown.
local rich_hover = table.concat({
  "<table>",
  '<tr><th align="left">Prop</th><th align="left">Description</th><th align="left">Default</th></tr>',
  "<tr>\n\t\t<td>modelValue <sup><em>required</em></sup> <sup><em>model</em></sup></td>",
  "\t\t<td>\n\nThe value.\nSecond line.<br><code>string</code></td>",
  "\t\t<td><code>'a'</code></td>\n\t</tr>",
  "<tr>\n\t\t<td><del>old</del></td>\n\t\t<td><code>`on${string}`</code></td>\n\t\t<td></td>\n\t</tr>",
  "\n<tr></tr><tr></tr>\n",
  '<tr><th align="left">Exposed</th><th align="left">Description</th><th></th></tr>',
  '<tr>\n\t\t<td>focus</td>\n\t\t<td colspan="2"><code>() => void</code></td>\n\t</tr>',
  "</table>",
}, "\n")
check("vue rich hover becomes markdown", require("vue_hover").to_markdown(rich_hover) == table.concat({
  "**Props**",
  "- `modelValue` *(required)* *(model)*: `string` = `'a'`",
  "  The value.",
  "  Second line.",
  "- ~~`old`~~: `` `on${string}` ``",
  "",
  "**Exposed**",
  "- `focus`: `() => void`",
}, "\n"))
check("vue plain hover is left alone", require("vue_hover").to_markdown("```ts\nconst x: number\n```") == nil)
local ts_plugins = vim.tbl_get(vim.lsp.config.vtsls or {}, "settings", "vtsls", "tsserver", "globalPlugins") or {}
check("vtsls loads @vue/typescript-plugin", ts_plugins[1] ~= nil and ts_plugins[1].name == "@vue/typescript-plugin")
check("vtsls attaches to vue", vim.tbl_contains(vim.tbl_get(vim.lsp.config.vtsls or {}, "filetypes") or {}, "vue"))

-- Vue 2 projects route away from Volar 3 (to vue_ls_vue2/vtsls_vue2).
for _, name in ipairs({ "vtsls_vue2", "vue_ls_vue2" }) do
  check("LSP enabled: " .. name, vim.lsp.is_enabled(name))
end
local function vue_buffer(vue_range)
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  vim.fn.writefile({ vim.json.encode({ dependencies = { vue = vue_range } }) }, dir .. "/package.json")
  local b = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(b, dir .. "/App.vue")
  return b
end
local function attaches(name, b)
  local root
  vim.lsp.config[name].root_dir(b, function(dir) root = dir end)
  return root ~= nil
end
local vue2_buf, vue3_buf = vue_buffer("^2.7.16"), vue_buffer("^3.5.0")
check("vue_ls skips Vue 2 projects", not attaches("vue_ls", vue2_buf))
check("vtsls skips Vue 2 projects", not attaches("vtsls", vue2_buf))
check("vue_ls attaches to Vue 3 projects", attaches("vue_ls", vue3_buf))
check("vtsls attaches to Vue 3 projects", attaches("vtsls", vue3_buf))
check("vue_ls_vue2 skips Vue 3 projects", not attaches("vue_ls_vue2", vue3_buf))
check("vtsls_vue2 skips Vue 3 projects", not attaches("vtsls_vue2", vue3_buf))

-- LSP keymaps are buffer-local, set on LspAttach; fire just our handler.
local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_exec_autocmds("LspAttach", { group = "lsp_attach", buffer = buf, data = { client_id = -1 } })
local function has_buf_map(mode, lhs)
  return vim.fn.maparg(lhs, mode, false, true).buffer == 1
end
check("K shows docs (LspAttach)", has_buf_map("n", "K"))
check("gd goto definition (LspAttach)", has_buf_map("n", "gd"))
check("gr references doesn't wait on grr", vim.fn.maparg("gr", "n", false, true).nowait == 1)
check("<leader>rn rename (LspAttach)", has_buf_map("n", "<leader>rn"))
check("<leader>f format operator (LspAttach)", has_buf_map("n", "<leader>f"))

local cmds = vim.api.nvim_get_commands({})
check("Format command", cmds.Format ~= nil)
check("Prettier command", cmds.Prettier ~= nil)
check("OR command", cmds.OR ~= nil)
check("Fold command", cmds.Fold ~= nil)

-- ── Treesitter (plugins/treesitter.lua) ──────────────────────────────────────
local installed = require("nvim-treesitter").get_installed()
for _, lang in ipairs({ "vue", "typescript", "python", "markdown" }) do
  check("parser installed: " .. lang, vim.tbl_contains(installed, lang))
end
local ts_buf = vim.api.nvim_create_buf(true, false)
vim.bo[ts_buf].filetype = "python"
check("treesitter highlighting starts on FileType", vim.treesitter.highlighter.active[ts_buf] ~= nil)
check("treesitter indentexpr set", vim.bo[ts_buf].indentexpr:find("nvim-treesitter", 1, true) ~= nil)
check("af function text object (textobjects)", has_map("o", "af"))
check("ic class text object (textobjects)", has_map("x", "ic"))

-- Regression: nvim-treesitter master's injection directives broke on nvim 0.12,
-- so any LSP hover with a fenced code block threw from the highlighter.
local function parses(lang, lines)
  local b = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)
  return (pcall(function() vim.treesitter.get_parser(b, lang):parse(true) end))
end
check("markdown code fence injection parses", parses("markdown", { "```html", "<div></div>", "```" }))
check("html <script type> injection parses", parses("html", { '<script type="text/javascript">let a = 1</script>' }))

-- ── Completion: blink's <CR> isn't clobbered by pear-tree ────────────────────
-- Both map <CR> buffer-locally on InsertEnter; blink must apply last so <CR>
-- accepts a completion (it falls back to pear-tree's mapping otherwise).
-- blink registers its InsertEnter autocmd once its fuzzy library is checked.
vim.wait(5000, function() return package.loaded["blink.cmp.keymap.apply"] ~= nil end)
vim.cmd("enew")
vim.cmd("doautocmd InsertEnter")
local cr = vim.fn.maparg("<CR>", "i", false, true)
check("blink's <CR> wins over pear-tree's", (cr.desc or ""):find("blink.cmp", 1, true) ~= nil)
check("<Tab> completion (blink)", (vim.fn.maparg("<Tab>", "i", false, true).desc or ""):find("blink.cmp", 1, true) ~= nil)

emit(("\n%d check(s) failed"):format(failures))
vim.cmd(failures > 0 and "cq" or "qa")
