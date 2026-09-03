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

for spec in \
  "pciutils https://github.com/pciutils/pciutils.git PCIUTILS_REVISION" \
  "eudev https://github.com/eudev-project/eudev.git EUDEV_REVISION"; do
  set -- $spec
  revision=$(sed -n "s/^$3=//p" "$ROOT/build/versions.env")
  source="$ROOT/sources/$1"
  if [[ -d "$source/.git" ]]; then git -C "$source" fetch --tags origin; else git clone "$2" "$source"; fi
  git -C "$source" checkout --detach "$revision"
  git -C "$source" status --porcelain | grep -q . && { echo "Source tree is not clean: $1" >&2; exit 1; } || true
done
