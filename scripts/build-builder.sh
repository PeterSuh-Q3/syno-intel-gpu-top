#!/usr/bin/env bash
set -euo pipefail

DSM_VERSION=${1:-7.4}
[[ "$DSM_VERSION" == "7.4" ]] || { echo 'Supported builder profile: 7.4' >&2; exit 2; }
ROOT=$(cd "$(dirname "$0")/.." && pwd)

# Docker Desktop keeps its credential helper inside the app bundle on macOS;
# non-interactive shells do not always inherit that directory in PATH.
if [[ -x /Applications/Docker.app/Contents/Resources/bin/docker-credential-desktop ]]; then
  export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
fi

docker build \
  --build-arg "DSM_VERSION=$DSM_VERSION" \
  --tag "syno-intel-gpu-top-builder:$DSM_VERSION" \
  --file "$ROOT/docker/Dockerfile" \
  "$ROOT"
