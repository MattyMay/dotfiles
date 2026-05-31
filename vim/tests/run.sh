#!/usr/bin/env bash
#
# Verifies the Neovim configuration in this repo:
#   1. Byte-compiles every Lua file (syntax check).
#   2. Sets up an isolated, throwaway nvim environment (never touches your real
#      ~/.config) and links the repo's config into it the same way
#      install.conf.yaml does.
#   3. Installs the plugins with lazy.nvim.
#   4. Asserts the runtime configuration matches expectations.
#
# Safe to run locally or in CI. Requires `nvim` on PATH (Node.js as well for a
# full coc.nvim run, though the checks here don't depend on it).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT

if ! command -v nvim >/dev/null 2>&1; then
  echo "error: nvim not found on PATH" >&2
  exit 1
fi

# Wrap potentially long-running nvim calls so a hang can't block forever.
run() {
  if command -v timeout >/dev/null 2>&1; then
    timeout 600 "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout 600 "$@"
  else
    "$@"
  fi
}

echo "==> [1/3] Lua syntax check"
nvim --headless --clean -c "luafile $REPO_ROOT/vim/tests/lint.lua" +qa

echo "==> [2/3] Installing plugins in an isolated environment"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT
export XDG_CONFIG_HOME="$TEST_HOME/config"
export XDG_DATA_HOME="$TEST_HOME/data"
export XDG_STATE_HOME="$TEST_HOME/state"
export XDG_CACHE_HOME="$TEST_HOME/cache"

mkdir -p "$XDG_CONFIG_HOME/nvim/lua"
ln -s "$REPO_ROOT/vim/init.lua" "$XDG_CONFIG_HOME/nvim/init.lua"
ln -s "$REPO_ROOT/vim/coc-settings.json" "$XDG_CONFIG_HOME/nvim/coc-settings.json"
for entry in "$REPO_ROOT"/vim/lua/*; do
  ln -s "$entry" "$XDG_CONFIG_HOME/nvim/lua/$(basename "$entry")"
done

run nvim --headless "+Lazy! sync" +qa

echo "==> [3/3] Verifying runtime configuration"
run nvim --headless -c "luafile $REPO_ROOT/vim/tests/verify.lua" +qa

echo "==> All checks passed"
