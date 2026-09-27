#!/usr/bin/env bash
set -euo pipefail
STAGE=${1:?staging root required}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
PREFIX="$STAGE/var/packages/syno-intel-gpu-top/target"
CC=${CC:-gcc}
mkdir -p "$PREFIX/bin/helper"
"$CC" -O2 -Wall -Wextra "$ROOT/spk/package/bin/helper/intel-gpu-top-root.c" -o "$PREFIX/bin/helper/intel-gpu-top-root"
chmod 0750 "$PREFIX/bin/helper/intel-gpu-top-root"
install -m 0755 "$ROOT/spk/package/bin/intel_gpu_top" "$PREFIX/bin/intel_gpu_top"
