#!/usr/bin/env bash
set -euo pipefail

NVIM_VERSIONS_DIR="${NVIM_VERSIONS_DIR:-$HOME/.local/share/nvim-versions}"
NVIM_LINK="${NVIM_LINK:-$HOME/.local/bin/nvim}"
KEEP_VERSIONS=3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIN_FILE="${PIN_FILE:-$SCRIPT_DIR/.nvim-version}"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Update neovim to the latest release, or manage installed versions.

Options:
  --version VERSION   Install a specific version (e.g. v0.11.0)
  --sync              Install the version recorded in .nvim-version
  --pin               Record the currently active version into .nvim-version
  --rollback          Switch to the previously active version
  --list              List installed versions
  -h, --help          Show this help

Upgrade workflow:
  $(basename "$0")               # install latest
  ./vim/tests/run.sh             # verify config still works
  $(basename "$0") --pin         # record version in .nvim-version
  git add .nvim-version && git commit
EOF
    exit 1
}

die() { echo "error: $*" >&2; exit 1; }

list_versions() {
    local current=""
    [[ -L "$NVIM_LINK" ]] && current=$(readlink "$NVIM_LINK")

    if [[ ! -d "$NVIM_VERSIONS_DIR" ]] || [[ -z "$(ls -A "$NVIM_VERSIONS_DIR" 2>/dev/null)" ]]; then
        echo "No managed nvim versions found in $NVIM_VERSIONS_DIR"
        return
    fi

    echo "Installed versions (active marked with *):"
    while IFS= read -r v; do
        local name
        name=$(basename "$v")
        if [[ "$v" == "$current" ]]; then
            echo "  * $name"
        else
            echo "    $name"
        fi
    done < <(ls -t "$NVIM_VERSIONS_DIR"/v* 2>/dev/null)

    if [[ -f "$PIN_FILE" ]]; then
        echo ""
        echo "Pinned in .nvim-version: $(cat "$PIN_FILE")"
    fi
}

get_latest_version() {
    curl -fsSL "https://api.github.com/repos/neovim/neovim/releases/latest" \
        | grep '"tag_name"' \
        | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/'
}

get_active_version() {
    [[ -x "$NVIM_LINK" ]] && "$NVIM_LINK" --version 2>/dev/null | awk 'NR==1{print $2}' || echo ""
}

read_pin_file() {
    [[ -f "$PIN_FILE" ]] || die ".nvim-version not found at $PIN_FILE"
    local v
    v=$(tr -d '[:space:]' < "$PIN_FILE")
    [[ -n "$v" ]] || die ".nvim-version is empty"
    echo "$v"
}

do_pin() {
    local current
    current=$(get_active_version)
    [[ -n "$current" ]] || die "No active managed nvim found at $NVIM_LINK"

    # Normalise: ensure version has a leading 'v'
    [[ "$current" == v* ]] || current="v$current"

    local pin_dir
    pin_dir=$(dirname "$PIN_FILE")
    [[ -d "$pin_dir" ]] || die "Directory $pin_dir does not exist"

    echo "$current" > "$PIN_FILE"
    echo "Pinned $current → $PIN_FILE"
}

download_version() {
    local version="$1"
    local dest="$NVIM_VERSIONS_DIR/$version"

    [[ -f "$dest" ]] && { echo "Version $version already downloaded."; echo "$dest"; return; }

    mkdir -p "$NVIM_VERSIONS_DIR"

    local url="https://github.com/neovim/neovim/releases/download/$version/nvim-linux-x86_64.tar.gz"
    local tmp
    tmp=$(mktemp -d)
    # shellcheck disable=SC2064
    trap "rm -rf '$tmp'" EXIT

    echo "Downloading nvim $version..."
    curl -fL --progress-bar "$url" -o "$tmp/nvim.tar.gz" \
        || die "Download failed. Check that $version exists at github.com/neovim/neovim/releases"

    tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
    cp "$tmp/nvim-linux-x86_64/bin/nvim" "$dest"
    chmod +x "$dest"
    echo "Saved nvim $version to $dest"
    echo "$dest"
}

activate_version() {
    local dest="$1"
    mkdir -p "$(dirname "$NVIM_LINK")"
    ln -sf "$dest" "$NVIM_LINK"
    echo "Activated: $("$NVIM_LINK" --version | head -1)"
}

prune_versions() {
    local current=""
    [[ -L "$NVIM_LINK" ]] && current=$(readlink "$NVIM_LINK")

    local -a versions=()
    while IFS= read -r v; do
        versions+=("$v")
    done < <(ls -t "$NVIM_VERSIONS_DIR"/v* 2>/dev/null)

    local count=${#versions[@]}
    (( count <= KEEP_VERSIONS )) && return

    for v in "${versions[@]:$KEEP_VERSIONS}"; do
        [[ "$v" == "$current" ]] && continue
        echo "Removing old version: $(basename "$v")"
        rm -f "$v"
    done
}

do_rollback() {
    [[ -L "$NVIM_LINK" ]] || die "No managed nvim symlink at $NVIM_LINK. Run the script without --rollback first."

    local current
    current=$(readlink "$NVIM_LINK")

    local prev=""
    while IFS= read -r v; do
        [[ "$v" != "$current" ]] && { prev="$v"; break; }
    done < <(ls -t "$NVIM_VERSIONS_DIR"/v* 2>/dev/null)

    [[ -n "$prev" ]] || die "No previous version to roll back to. Only $(basename "$current") is installed."

    ln -sf "$prev" "$NVIM_LINK"
    echo "Rolled back: $(basename "$current") → $(basename "$prev")"
    "$NVIM_LINK" --version | head -1
}

# ── argument parsing ───────────────────────────────────────────────────────────
TARGET_VERSION=""
DO_ROLLBACK=false
DO_LIST=false
DO_PIN=false
DO_SYNC=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)  [[ $# -gt 1 ]] || die "--version requires an argument"; TARGET_VERSION="$2"; shift 2 ;;
        --sync)     DO_SYNC=true; shift ;;
        --pin)      DO_PIN=true; shift ;;
        --rollback) DO_ROLLBACK=true; shift ;;
        --list)     DO_LIST=true; shift ;;
        -h|--help)  usage ;;
        *)          echo "Unknown argument: $1"; usage ;;
    esac
done

# ── dispatch ───────────────────────────────────────────────────────────────────
$DO_LIST     && { list_versions; exit 0; }
$DO_PIN      && { do_pin;        exit 0; }
$DO_ROLLBACK && { do_rollback;   exit 0; }
$DO_SYNC     && TARGET_VERSION=$(read_pin_file)

if [[ -z "$TARGET_VERSION" ]]; then
    echo "Checking latest nvim release..."
    TARGET_VERSION=$(get_latest_version)
    [[ -n "$TARGET_VERSION" ]] || die "Could not determine latest version. Check your internet connection."
    echo "Latest: $TARGET_VERSION"

    current=$(get_active_version)
    if [[ "v$current" == "$TARGET_VERSION" || "$current" == "$TARGET_VERSION" ]]; then
        echo "Already on $current. Pass --version to reinstall, or --list to see what's installed."
        exit 0
    fi
fi

dest=$(download_version "$TARGET_VERSION")
activate_version "$dest"
prune_versions
