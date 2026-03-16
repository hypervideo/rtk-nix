#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
UPSTREAM_REPO="https://github.com/rtk-ai/rtk.git"

CURRENT_VERSION=$(grep 'version = "' "$REPO_DIR/default.nix" | head -1 | sed 's/.*version = "\(.*\)";/\1/')
echo "Current version: $CURRENT_VERSION"

LATEST_VERSION=$(
  git ls-remote --tags --refs "$UPSTREAM_REPO" \
    | sed -n 's|.*refs/tags/v\([0-9]\+\.[0-9]\+\.[0-9]\+\)$|\1|p' \
    | sort -V \
    | tail -n 1
)
echo "Latest release version: $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo "Already up to date."
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "UPDATED=false" >> "$GITHUB_OUTPUT"
  fi
  exit 0
fi

SRC_URL="https://github.com/rtk-ai/rtk/archive/refs/tags/v${LATEST_VERSION}.tar.gz"
SRC_HASH=$(nix store prefetch-file --json --unpack "$SRC_URL" | jq -r '.hash')
echo "Source hash: $SRC_HASH"

sed "s|version = \"$CURRENT_VERSION\"|version = \"$LATEST_VERSION\"|" "$REPO_DIR/default.nix" \
  | sed "s|hash = \".*\"|hash = \"$SRC_HASH\"|" \
  > "$REPO_DIR/default.nix.tmp"
mv "$REPO_DIR/default.nix.tmp" "$REPO_DIR/default.nix"

echo "Updated rtk to $LATEST_VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "VERSION=$LATEST_VERSION" >> "$GITHUB_OUTPUT"
  echo "UPDATED=true" >> "$GITHUB_OUTPUT"
fi
