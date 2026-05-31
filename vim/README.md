# Neovim config

Lua config managed with [lazy.nvim](https://github.com/folke/lazy.nvim). CI verifies the config loads and all plugins install cleanly on each push.

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
└── .nvim-version          pinned neovim version used by CI
```

## Neovim version

The file `.nvim-version` records the version that CI runs against. When the tests pass on a given version, that version is committed here so the green badge means something specific.

### Upgrading

```bash
# 1. Install the latest release
./vim/update-nvim.sh

# 2. Verify the config still works
./vim/tests/run.sh

# 3. Record the new version
./vim/update-nvim.sh --pin

# 4. Commit
git add vim/.nvim-version && git commit -m "nvim: bump to vX.Y.Z"
```

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
./vim/tests/run.sh
```

Uses a throwaway XDG environment so it never touches your real `~/.config/nvim`.
