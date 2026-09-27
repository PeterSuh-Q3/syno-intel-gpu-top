#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
IMAGE=${IMAGE:-dante90/syno-intel-gpu-top-builder:debian12-native}
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  docker pull "$IMAGE" || "$ROOT/scripts/build-builder.sh"
fi
docker run --rm -u 0 -v "$ROOT:/work" -w /work \
  -e COMPILE_JOBS="${COMPILE_JOBS:-$(sysctl -n hw.ncpu)}" "$IMAGE" bash -lc \
  './scripts/build-target-deps.sh && ./scripts/build-runtime.sh && ./scripts/package-spk.sh "work/x86_64-native/stage" && ./scripts/create-runtime-bundle.sh "work/x86_64-native/stage"'
