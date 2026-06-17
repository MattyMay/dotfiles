#!/usr/bin/env bash
#
# Verifies the Neovim configuration in this repo:
#   1. Byte-compiles every Lua file (syntax check).
#   2. Sets up an isolated nvim environment (never touches your real ~/.config)
#      and links the repo's config into it the same way install.conf.yaml does.
#      Locally this is a persistent cache (TEST_FRESH=1 resets it); in CI the
#      caller provides the XDG dirs.
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

# Run a command silently, surfacing its output only if it fails.
quiet() {
  local out rc
  if out="$(run "$@" 2>&1)"; then
    return 0
  fi
  rc=$?
  printf '%s\n' "$out" >&2
  return "$rc"
}

echo "==> [1/3] Lua syntax check"
run nvim --headless --clean -c "luafile $REPO_ROOT/vim/tests/lint.lua" +qa

echo
echo "==> [2/3] Installing plugins in an isolated environment"
# Use a caller-provided XDG environment if one is set (e.g. CI, so the plugin
# directory under XDG_DATA_HOME can be cached across runs). Otherwise fall back
# to a persistent local cache so repeat local runs reuse installed plugins and
# parsers instead of cold-starting. Set TEST_FRESH=1 to force a clean run.
if [ -n "${XDG_CONFIG_HOME:-}" ] && [ -n "${XDG_DATA_HOME:-}" ]; then
  echo "    using caller-provided XDG environment"
else
  TEST_HOME="${NVIM_TEST_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-nvim-test}"
  if [ -n "${TEST_FRESH:-}" ]; then
    echo "    TEST_FRESH set -- wiping cache at $TEST_HOME"
    rm -rf "$TEST_HOME"
  fi
  echo "    using local cache at $TEST_HOME (TEST_FRESH=1 to reset)"
  export XDG_CONFIG_HOME="$TEST_HOME/config"
  export XDG_DATA_HOME="$TEST_HOME/data"
  export XDG_STATE_HOME="$TEST_HOME/state"
  export XDG_CACHE_HOME="$TEST_HOME/cache"
fi

# Rebuild the config dir from scratch each run (it is never cached); the plugin
# directory under XDG_DATA_HOME may be a warm cache and is left untouched.
rm -rf "$XDG_CONFIG_HOME/nvim"
mkdir -p "$XDG_CONFIG_HOME/nvim/lua"
ln -sf "$REPO_ROOT/vim/init.lua" "$XDG_CONFIG_HOME/nvim/init.lua"
ln -sf "$REPO_ROOT/vim/coc-settings.json" "$XDG_CONFIG_HOME/nvim/coc-settings.json"
for entry in "$REPO_ROOT"/vim/lua/*; do
  ln -sf "$entry" "$XDG_CONFIG_HOME/nvim/lua/$(basename "$entry")"
done
# Copy (not symlink) the lockfile: lazy rewrites it during install/restore, so a
# symlink would clobber the committed repo copy.
cp "$REPO_ROOT/vim/lazy-lock.json" "$XDG_CONFIG_HOME/nvim/lazy-lock.json"

# LAZY_MODE=pinned (default) installs the exact commits in lazy-lock.json, so CI
# verifies what we actually ship. LAZY_MODE=latest floats every plugin to its
# newest commit -- a canary for upstream breakage, meant to run on a schedule.
# (restore/update only touch already-installed plugins, hence install first.)
case "${LAZY_MODE:-pinned}" in
  pinned)
    echo "    LAZY_MODE=pinned (lazy-lock.json)"
    quiet nvim --headless "+Lazy! install" "+Lazy! restore" +qa
    ;;
  latest)
    echo "    LAZY_MODE=latest (floating newest commits)"
    quiet nvim --headless "+Lazy! sync" +qa
    ;;
  *)
    echo "error: unknown LAZY_MODE='${LAZY_MODE}' (expected 'pinned' or 'latest')" >&2
    exit 1
    ;;
esac

# Install parsers now so verify's async auto_install doesn't scribble over it.
quiet nvim --headless \
  -c 'lua require("nvim-treesitter.install").ensure_installed_sync(unpack(require("nvim-treesitter.configs").get_ensure_installed_parsers()))' \
  +qa

echo
echo "==> [3/3] Verifying runtime configuration"
run nvim --headless -c "luafile $REPO_ROOT/vim/tests/verify.lua" +qa

echo
echo "==> All checks passed"
