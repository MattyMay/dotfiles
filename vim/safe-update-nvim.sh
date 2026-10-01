#!/usr/bin/env bash
# Update nvim to the latest release, gated on the nvim-config CI workflow.
#
#   - Latest CI run is green and tested the latest release → update.
#   - Latest CI run is red                                → warn, ask first.
#   - Latest CI run tested an older version               → offer to dispatch a
#     CI run against the latest release and wait, or update without CI.
#
# Installation itself is delegated to update-nvim.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/update-nvim.sh"
WORKFLOW="nvim-config.yml"
BRANCH="main"

die() { echo "error: $*" >&2; exit 1; }

# Prompt with a [y/N] question; returns 0 on yes.
confirm() {
    local reply
    read -rp "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy] ]]
}

# The workflow names its install step "Install Neovim <version>", so the
# version a run tested is recoverable from its step names.
run_tested_version() {
    gh run view "$1" --json jobs \
        --jq '[.jobs[].steps[].name | capture("^Install Neovim (?<v>v\\S+)$").v][0] // ""'
}

# Most recent completed scheduled or manually dispatched run on $BRANCH, as
# "id conclusion createdAt url". Push runs are ignored: they test whatever
# branch was pushed, not the weekly check.
latest_run() {
    gh run list --workflow "$WORKFLOW" --branch "$BRANCH" --status completed -L 30 \
        --json databaseId,event,conclusion,createdAt,url \
        --jq '[.[] | select(.event == "schedule" or .event == "workflow_dispatch")][0]
              | select(.) | "\(.databaseId) \(.conclusion) \(.createdAt) \(.url)"'
}

workflow_state() {
    gh api "repos/{owner}/{repo}/actions/workflows/$WORKFLOW" --jq .state
}

newest_dispatch_id() {
    gh run list --workflow "$WORKFLOW" --event workflow_dispatch -L 1 \
        --json databaseId --jq '.[0].databaseId // 0'
}

# Dispatch a CI run against $1, wait for it, and set RUN_* globals from it.
dispatch_and_wait() {
    local version="$1" before id=""

    # GitHub disables scheduled workflows after 60 days of repo inactivity, and
    # a disabled workflow can't be dispatched either.
    if [[ "$(workflow_state)" != "active" ]]; then
        echo "Re-enabling $WORKFLOW (GitHub disabled it for inactivity)..."
        gh workflow enable "$WORKFLOW"
    fi

    before=$(newest_dispatch_id)
    gh workflow run "$WORKFLOW" --ref "$BRANCH" -f nvim_version="$version" \
        || die "Dispatch failed. Is the nvim_version input pushed to $BRANCH?"

    echo -n "Waiting for the run to start"
    for _ in $(seq 30); do
        id=$(newest_dispatch_id)
        (( id > before )) && break
        echo -n "."
        sleep 2
    done
    echo
    (( id > before )) || die "Dispatched run never appeared; check GitHub Actions."

    # --exit-status makes watch fail on a red run; we read the result ourselves.
    gh run watch "$id" --exit-status --interval 10 || true

    RUN_ID="$id"
    RUN_CONCLUSION=$(gh run view "$id" --json conclusion --jq .conclusion)
    RUN_URL=$(gh run view "$id" --json url --jq .url)
    RUN_VERSION=$(run_tested_version "$id")
}

do_update() {
    "$UPDATE_SCRIPT" --version "$1"
    if [[ "$RUN_VERSION" == "$1" && "$RUN_CONCLUSION" == "success" ]]; then
        echo
        echo "CI is green on $1. To record it: $UPDATE_SCRIPT --pin && git add vim/.nvim-version"
    fi
}

command -v gh &>/dev/null || die "gh (GitHub CLI) is required"
gh auth status &>/dev/null || die "gh is not authenticated; run: gh auth login"
cd "$SCRIPT_DIR"

echo "Checking latest nvim release..."
latest=$(gh api repos/neovim/neovim/releases/latest --jq .tag_name)
[[ -n "$latest" ]] || die "Could not determine latest nvim release"
current=$(nvim --version 2>/dev/null | awk 'NR==1{print $2}' || true)
echo "Latest: $latest   Installed: ${current:-none}"
[[ "$current" == "$latest" ]] && { echo "Already up to date."; exit 0; }

RUN_ID="" RUN_CONCLUSION="" RUN_URL="" RUN_VERSION=""
if read -r RUN_ID RUN_CONCLUSION run_date RUN_URL < <(latest_run) && [[ -n "$RUN_ID" ]]; then
    RUN_VERSION=$(run_tested_version "$RUN_ID")
    echo "Last CI run: $RUN_CONCLUSION on ${RUN_VERSION:-unknown version} (${run_date%T*})"
    echo "  $RUN_URL"
    if [[ "$(workflow_state)" != "active" ]]; then
        echo "  note: $WORKFLOW is disabled, so the weekly run isn't happening."
    fi
else
    echo "No completed scheduled or dispatched CI run found."
fi

if [[ "$RUN_VERSION" != "$latest" ]]; then
    echo
    echo "CI hasn't tested $latest yet."
    echo "  [r] run CI against $latest and wait for results"
    echo "  [u] update now without CI"
    echo "  [q] quit"
    read -rp "Choice [r/u/q]: " choice
    case "$choice" in
        r|R) dispatch_and_wait "$latest" ;;
        u|U) do_update "$latest"; exit 0 ;;
        *)   echo "Aborted."; exit 0 ;;
    esac
fi

if [[ "$RUN_CONCLUSION" == "success" ]]; then
    echo "CI is green on $latest. Updating."
    do_update "$latest"
else
    echo
    echo "WARNING: the CI run for $latest finished with '$RUN_CONCLUSION'."
    echo "  $RUN_URL"
    if confirm "Update to $latest anyway?"; then
        do_update "$latest"
    else
        echo "Aborted."
    fi
fi
