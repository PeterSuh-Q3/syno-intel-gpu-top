#!/usr/bin/env bash
set -euo pipefail
STAGE=${1:?staging root required}
KERNEL_FLAVOR=${2:-kernel5.10.55}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
PREFIX="$STAGE/var/packages/syno-intel-gpu-top/target"
CC=${CC:-/opt/kvmx64/bin/x86_64-pc-linux-gnu-gcc}
mkdir -p "$PREFIX/bin/helper"
"$CC" -O2 -Wall -Wextra "$ROOT/spk/package/bin/helper/intel-gpu-top-root.c" -o "$PREFIX/bin/helper/intel-gpu-top-root"
chmod 0750 "$PREFIX/bin/helper/intel-gpu-top-root"
install -m 0755 "$ROOT/spk/package/bin/intel_gpu_top" "$PREFIX/bin/intel_gpu_top"
printf '%s\n' "$KERNEL_FLAVOR" > "$PREFIX/KERNEL_FLAVOR"
