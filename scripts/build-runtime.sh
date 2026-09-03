#!/usr/bin/env bash
set -euo pipefail

ROOT=${ROOT:-/work}
PLATFORM=${PLATFORM:-kvmx64}
DSM_VERSION=${DSM_VERSION:-7.4}
KERNEL_FLAVOR=${KERNEL_FLAVOR:-kernel5.10.55}
PREFIX=/var/packages/syno-intel-gpu-top/target
BUILD="$ROOT/work/${PLATFORM}-${DSM_VERSION}"
STAGE="$BUILD/stage"
DEPS="$ROOT/work/deps/${PLATFORM}-${DSM_VERSION}"
CROSS_FILE="$ROOT/work/profiles/${PLATFORM}-${DSM_VERSION}.ini"
TOOLCHAIN=${TOOLCHAIN_BIN:-/opt/${PLATFORM}/bin}
JOBS=${COMPILE_JOBS:-$(nproc)}

test -x "$TOOLCHAIN/x86_64-pc-linux-gnu-gcc" || { echo 'Synology toolchain missing' >&2; exit 1; }
test -d "$ROOT/sources/igt-gpu-tools" || { echo 'IGT source missing; run fetch-sources.sh' >&2; exit 1; }
test -f "$DEPS/lib/pkgconfig/glib-2.0.pc" || {
  echo "Target dependency prefix missing: $DEPS" >&2
  echo 'Run scripts/build-target-deps.sh before building intel_gpu_top.' >&2
  exit 1
}
"$ROOT/scripts/generate-cross-file.sh" "$PLATFORM" "$DSM_VERSION" >/dev/null
mkdir -p "$BUILD" "$STAGE"
export PKG_CONFIG_SYSROOT_DIR=
export PKG_CONFIG_LIBDIR="$DEPS/lib/pkgconfig:$DEPS/share/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_LIBDIR"
export C_INCLUDE_PATH="$DEPS/include"
export LDFLAGS="-L$DEPS/lib -Wl,-rpath,\$ORIGIN/../lib"
if [[ -d "$BUILD/igt/meson-private" ]]; then
  MESON_SETUP=(meson setup --wipe "$BUILD/igt" "$ROOT/sources/igt-gpu-tools")
else
  MESON_SETUP=(meson setup "$BUILD/igt" "$ROOT/sources/igt-gpu-tools")
fi
"${MESON_SETUP[@]}" --cross-file "$CROSS_FILE" \
  --prefix="$PREFIX" -Dtests=disabled -Ddocs=disabled -Dman=disabled \
  -Dchamelium=disabled -Doverlay=disabled -Dxe_driver=disabled -Dlibdrm_drivers=intel
ninja -C "$BUILD/igt" -j"$JOBS" tools/intel_gpu_top
install -Dm755 "$BUILD/igt/tools/intel_gpu_top" "$STAGE$PREFIX/bin/intel_gpu_top.real"
mkdir -p "$STAGE$PREFIX/lib"
find "$DEPS/lib" -maxdepth 1 \( -type f -o -type l \) -name '*.so*' -exec cp -a {} "$STAGE$PREFIX/lib/" \;
"$TOOLCHAIN/x86_64-pc-linux-gnu-strip" "$STAGE$PREFIX/bin/intel_gpu_top.real" || true
"$ROOT/scripts/refresh-spk-stage.sh" "$STAGE" "$KERNEL_FLAVOR"
