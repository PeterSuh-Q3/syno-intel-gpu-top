#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)

# Docker Desktop keeps its credential helper inside the app bundle on macOS;
# non-interactive shells do not always inherit that directory in PATH.
if [[ -x /Applications/Docker.app/Contents/Resources/bin/docker-credential-desktop ]]; then
  export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
fi

docker build \
  --tag "dante90/syno-intel-gpu-top-builder:debian12-native" \
  --file "$ROOT/docker/Dockerfile" \
  "$ROOT"
