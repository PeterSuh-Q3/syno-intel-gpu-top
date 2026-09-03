#!/usr/bin/env bash
set -euo pipefail

ROOT=${ROOT:-/work}
PLATFORM=${PLATFORM:-kvmx64}
DSM_VERSION=${DSM_VERSION:-7.4}
TOOLCHAIN=${TOOLCHAIN_BIN:-/opt/${PLATFORM}/bin}
PREFIX="$ROOT/work/deps/${PLATFORM}-${DSM_VERSION}"
BUILD="$ROOT/work/deps-build/${PLATFORM}-${DSM_VERSION}"
JOBS=${COMPILE_JOBS:-$(nproc)}
CC="$TOOLCHAIN/x86_64-pc-linux-gnu-gcc"
AR="$TOOLCHAIN/x86_64-pc-linux-gnu-ar"
RANLIB="$TOOLCHAIN/x86_64-pc-linux-gnu-ranlib"

for source in eudev pciutils; do test -d "$ROOT/sources/$source" || { echo "missing source: $source" >&2; exit 1; }; done
rm -rf "$PREFIX" "$BUILD"
mkdir -p "$PREFIX/lib/pkgconfig" "$PREFIX/include/pci" "$BUILD"

# eudev builds only libudev: no udevd, rules, HWDB, kmod, SELinux, or blkid.
cp -a "$ROOT/sources/eudev" "$BUILD/eudev"
pushd "$BUILD/eudev" >/dev/null
autoreconf -fi >/dev/null
CC="$CC" AR="$AR" RANLIB="$RANLIB" ./configure --prefix="$PREFIX" \
  --disable-programs --disable-blkid --disable-selinux --disable-kmod \
  --disable-hwdb --disable-manpages --disable-mtd_probe >/dev/null
make -j"$JOBS" >/dev/null
make install >/dev/null
popd >/dev/null

# pciutils supplies libpci only; DNS, compressed IDs, HWDB, and kmod are off.
cp -a "$ROOT/sources/pciutils" "$BUILD/pciutils"
make -C "$BUILD/pciutils" -j"$JOBS" CROSS_COMPILE="${TOOLCHAIN}/x86_64-pc-linux-gnu-" \
  SHARED=yes ZLIB=no DNS=no HWDB=no LIBKMOD=no PREFIX="$PREFIX" lib/libpci.so.3.13.0 >/dev/null
install -Dm755 "$BUILD/pciutils/lib/libpci.so.3.13.0" "$PREFIX/lib/libpci.so.3.13.0"
ln -sf libpci.so.3.13.0 "$PREFIX/lib/libpci.so.3"
ln -sf libpci.so.3 "$PREFIX/lib/libpci.so"
install -Dm644 "$BUILD/pciutils/lib/"{pci.h,header.h,types.h,config.h} "$PREFIX/include/pci/"
install -Dm644 "$BUILD/pciutils/lib/libpci.pc" "$PREFIX/lib/pkgconfig/libpci.pc"

# IGT's project-wide Meson discovery probes more libraries than the selected
# intel_gpu_top target links.  These interface-only markers expose headers
# already supplied by the build image. Final ELF validation rejects any
# unexpected dynamic dependency, so they can never leak into the SPK runtime.
cp -a /usr/include/libdrm/. "$PREFIX/include/"
cp /usr/include/xf86drm*.h /usr/include/pciaccess.h "$PREFIX/include/"
for name in libdrm libdrm_intel pciaccess libkmod libdw pixman-1 cairo glib-2.0; do
  printf 'Name: %s\nDescription: IGT build interface only\nVersion: 99.0\nLibs:\nCflags: -I%s/include\n' "$name" "$PREFIX" > "$PREFIX/lib/pkgconfig/$name.pc"
done
# Do not let absolute build-prefix paths become a runtime RPATH. The linker
# receives -L$PREFIX/lib explicitly in build-runtime.sh.
sed -i -E 's#^-L[^ ]+ ##' "$PREFIX/lib/pkgconfig/libudev.pc" 2>/dev/null || true
sed -i -E 's#^Libs:.*#Libs: -ludev#' "$PREFIX/lib/pkgconfig/libudev.pc"
sed -i -E 's#^Libs:.*#Libs: -lpci#' "$PREFIX/lib/pkgconfig/libpci.pc"
# The selected tool does not link zlib, but the IGT root Meson file probes it.
"$AR" rcs "$PREFIX/lib/libz.a"
printf '%s\n' "$PREFIX"
