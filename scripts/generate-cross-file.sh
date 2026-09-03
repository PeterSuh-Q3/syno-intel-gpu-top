#!/usr/bin/env bash
set -euo pipefail

PLATFORM=${1:-kvmx64}
DSM_VERSION=${2:-7.4}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
TOOLCHAIN=${TOOLCHAIN_BIN:-"/opt/${PLATFORM}/bin"}
OUT="$ROOT/work/profiles/${PLATFORM}-${DSM_VERSION}.ini"
test -x "$TOOLCHAIN/x86_64-pc-linux-gnu-gcc"
mkdir -p "$(dirname "$OUT")"
cat > "$OUT" <<EOF
[binaries]
c = '${TOOLCHAIN}/x86_64-pc-linux-gnu-gcc'
cpp = '${TOOLCHAIN}/x86_64-pc-linux-gnu-g++'
ar = '${TOOLCHAIN}/x86_64-pc-linux-gnu-ar'
strip = '${TOOLCHAIN}/x86_64-pc-linux-gnu-strip'
pkgconfig = 'pkg-config'

[properties]
needs_exe_wrapper = true

[host_machine]
system = 'linux'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
EOF
printf '%s\n' "$OUT"
