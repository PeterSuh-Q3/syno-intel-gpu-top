#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SOURCE="$ROOT/sources/igt-gpu-tools"
REVISION=$(sed -n 's/^IGT_REVISION=//p' "$ROOT/build/versions.env")
[[ -n "$REVISION" ]] || { echo 'Missing IGT_REVISION' >&2; exit 2; }

if [[ -d "$SOURCE/.git" ]]; then
  git -C "$SOURCE" fetch --tags origin
else
  git clone https://gitlab.freedesktop.org/drm/igt-gpu-tools.git "$SOURCE"
fi
git -C "$SOURCE" checkout --detach "$REVISION"
git -C "$SOURCE" status --porcelain | grep -q . && { echo 'Source tree is not clean' >&2; exit 1; } || true
printf 'IGT source pinned to %s\n' "$REVISION"
