#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SOURCE="$ROOT/sources/igt-gpu-tools"
REVISION=5cdf45cac43700386fd6d48e59f494a35aa171d0

if [[ -d "$SOURCE/.git" ]]; then
  git -C "$SOURCE" fetch --tags origin
else
  git clone https://gitlab.freedesktop.org/drm/igt-gpu-tools.git "$SOURCE"
fi
git -C "$SOURCE" checkout --detach "$REVISION"
git -C "$SOURCE" status --porcelain | grep -q . && { echo 'Source tree is not clean' >&2; exit 1; } || true
printf 'IGT source pinned to %s\n' "$REVISION"
