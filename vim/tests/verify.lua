-- Verifies that the Neovim config loads and applies as expected, after plugins
-- have been installed. Run with: nvim --headless -c 'luafile verify.lua'
-- Exits non-zero (via :cq) if any check fails.

local failures = 0
local function check(name, cond)
  if cond then
    print("ok   - " .. name)
  else
    print("FAIL - " .. name)
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
  "coc.nvim",
  "tokyonight.nvim",
  "nvim-treesitter",
  "lualine.nvim",
  "indent-blankline.nvim",
  "copilot.vim",
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
check("coc_global_extensions is a list", type(vim.g.coc_global_extensions) == "table")
check("coc-pyright extension configured", vim.tbl_contains(vim.g.coc_global_extensions or {}, "coc-pyright"))
check("coc-lua extension configured", vim.tbl_contains(vim.g.coc_global_extensions or {}, "coc-lua"))
check("tmux_navigator_no_mappings = 1", vim.g.tmux_navigator_no_mappings == 1)
check("copilot_no_tab_map = 1", vim.g.copilot_no_tab_map == 1)
check("emmet expand key is <tab>", vim.g.user_emmet_expandabbr_key == "<tab>")
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
check("K shows docs (coc)", has_map("n", "K"))
check("gd goto definition (coc)", has_map("n", "gd"))
check("<Tab> completion (coc)", has_map("i", "<Tab>"))

-- ── CoC helper + user commands (plugins/coc.lua config) ──────────────────────
check("check_backspace global helper", type(_G.check_backspace) == "function")
local cmds = vim.api.nvim_get_commands({})
check("Format command", cmds.Format ~= nil)
check("Prettier command", cmds.Prettier ~= nil)
check("CocSplitIfNotOpen command", cmds.CocSplitIfNotOpen ~= nil)

-- ── Treesitter configured ────────────────────────────────────────────────────
check("nvim-treesitter.configs loadable", (pcall(require, "nvim-treesitter.configs")))

print(("\n%d check(s) failed"):format(failures))
vim.cmd(failures > 0 and "cq" or "qa")
