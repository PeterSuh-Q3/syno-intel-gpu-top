#!/usr/bin/env bash
set -euo pipefail
PLATFORM=${1:-kvmx64}
DSM_VERSION=${2:-7.4}
KERNEL_FLAVOR=${3:-kernel5.10.55}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
IMAGE=${IMAGE:-dante90/syno-intel-gpu-top-builder:${DSM_VERSION}}
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  docker pull "$IMAGE" || "$ROOT/scripts/build-builder.sh" "$DSM_VERSION"
fi
docker run --rm -u 0 -v "$ROOT:/work" -w /work \
  -e PLATFORM="$PLATFORM" -e DSM_VERSION="$DSM_VERSION" -e KERNEL_FLAVOR="$KERNEL_FLAVOR" \
  -e COMPILE_JOBS="${COMPILE_JOBS:-$(sysctl -n hw.ncpu)}" "$IMAGE" bash -lc \
  './scripts/build-target-deps.sh && ./scripts/build-runtime.sh && ./scripts/package-spk.sh "work/${PLATFORM}-${DSM_VERSION}/stage" "$KERNEL_FLAVOR"'
