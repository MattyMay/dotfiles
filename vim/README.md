# Neovim config

Lua config managed with [lazy.nvim](https://github.com/folke/lazy.nvim). CI verifies the config loads and all plugins install cleanly on each push. A weekly run (Mondays) also tests the pinned nvim with the newest plugin commits, and the newest nvim release with the pinned plugins, so breakage from either side shows up before you update.

## Files

```
vim/
├── init.lua               entry point
├── lua/
│   ├── settings.lua
│   ├── keymaps.lua
│   └── plugins/           one file per plugin or plugin group
├── tests/
│   ├── run.sh             test runner (safe locally and in CI)
│   ├── lint.lua           Lua syntax check
│   └── verify.lua         runtime assertions
├── update-nvim.sh         install / upgrade / rollback script
├── safe-update-nvim.sh    upgrade to latest, gated on CI results
└── .nvim-version          pinned neovim version used by CI
```

## Treesitter

Uses nvim-treesitter's `main` branch, which is the only branch that supports nvim 0.12. `plugins/treesitter.lua` installs the listed parsers and any other parser a filetype needs, then enables highlighting and indent for each buffer. Building parsers needs the [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/releases) 0.26.1 or newer on PATH, and a C compiler. Don't install the CLI with npm. CI downloads a pinned release binary.

## Language servers

LSP uses nvim's built-in client (`plugins/lsp.lua`), with server configs from nvim-lspconfig. The first interactive start installs any missing servers, plus prettier, through [mason](https://github.com/mason-org/mason.nvim). Most of them need Node.js on PATH. `<space>e` opens `:Mason`. Headless runs (tests, CI) skip the install.

To add a server, append its lspconfig name to `servers` in `plugins/lsp.lua`.

Vue 2 projects use Volar 2.2.8 (`vue_ls_vue2` + `vtsls_vue2`), the version coc-volar ran. Vue 3 projects use mason's current Volar (`vue_ls` + `vtsls`). The choice depends on the `vue` version in the nearest `package.json`. mason holds only one version of each package, so npm installs the pinned 2.2.8 set into `stdpath("data")/vue2-language-server` on the first interactive start. To change the pins, edit `vue2.packages`.

## Neovim version

The file `.nvim-version` records the version that CI runs against. When the tests pass on a given version, that version is committed here so the green badge means something specific.

### Upgrading

```bash
# 1. Install the latest release
./vim/update-nvim.sh

# 2. Verify the config still works
./vim/test.sh

# 3. Record the new version
./vim/update-nvim.sh --pin

# 4. Commit
git add vim/.nvim-version && git commit -m "nvim: bump to vX.Y.Z"
```

Or let CI vet the release first:

```bash
./vim/safe-update-nvim.sh
```

It checks the latest scheduled or dispatched CI run, looking only at the jobs that tested the latest release. If they passed, it updates. If they failed, it warns and asks before updating. If no job tested the latest release, it offers to dispatch a CI run against the new release and wait for it, or to update without CI.

### Rolling back

If something breaks after upgrading, roll back before touching `.nvim-version`:

```bash
./vim/update-nvim.sh --rollback
```

### Other commands

```bash
./vim/update-nvim.sh --list              # show installed versions and current pin
./vim/update-nvim.sh --sync              # install the version in .nvim-version
./vim/update-nvim.sh --version v0.10.4   # install a specific version
```

The script stores versioned binaries in `~/.local/share/nvim-versions/` and keeps `~/.local/bin/nvim` as a symlink to the active one. The last three versions are retained for rollback.

## Running tests locally

```bash
./vim/test.sh
```

Uses a throwaway XDG environment so it never touches your real `~/.config/nvim`.
