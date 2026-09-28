#!/usr/bin/env bash
# Produce the minimal Manager-consumable runtime from an already built SPK stage.
set -euo pipefail

STAGE=${1:?staging root required}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
PACKAGE=syno-intel-gpu-top
VERSION=$(sed -n 's/^version="\([^"]*\)"$/\1/p' "$ROOT/spk/INFO" | head -n 1)
SOURCE="$STAGE/var/packages/$PACKAGE/target"
OUT="$ROOT/dist"
NAME="${PACKAGE}-runtime-${VERSION}-x86_64"
WORK="$ROOT/work/runtime-bundle-x86_64"
IGT_VERSION=$(sed -n 's/^IGT_VERSION=//p' "$ROOT/build/versions.env")
IGT_REVISION=$(awk '$1 == "igt-gpu-tools" {print $2}' "$ROOT/build/sources.lock")
GCC_VERSION=$(gcc -dumpfullversion)
ELF="$SOURCE/bin/intel_gpu_top.real"
GLIBC_MAX=$(readelf --version-info "$ELF" | grep -oE 'GLIBC_[0-9]+(\.[0-9]+)+' | cut -d_ -f2 | sort -V | tail -n 1)
test -n "$GLIBC_MAX" || { echo 'could not determine the ELF glibc requirement' >&2; exit 1; }
GLIBC_LIMIT=$(printf '%s\n%s\n' "$GLIBC_MAX" 2.36 | sort -V | tail -n 1)
test "$GLIBC_LIMIT" = 2.36 || { echo "ELF requires GLIBC_$GLIBC_MAX; DSM 7.4 baseline is GLIBC_2.36" >&2; exit 1; }

test -x "$SOURCE/bin/intel_gpu_top.real"
test -d "$SOURCE/lib"
rm -rf "$WORK"
mkdir -p "$WORK/runtime/bin" "$WORK/runtime/lib"
# The SPK's launcher and setuid helper deliberately point at its package-owned
# path.  Manager embeds only the real monitor and libraries, then provides its
# own controlled server-side execution path.
cp -a "$SOURCE/bin/intel_gpu_top.real" "$WORK/runtime/bin/"
ln -s intel_gpu_top.real "$WORK/runtime/bin/intel_gpu_top"
cp -a "$SOURCE/lib/." "$WORK/runtime/lib/"

{
  printf '{\n  "package": "%s",\n  "version": "%s",\n  "architecture": "x86_64",\n  "source": {"igt_version": "%s", "igt_revision": "%s"},\n  "builder": {"image": "Debian 12 native x86_64", "gcc": "%s"},\n  "kernel_requirement": "i915 PMU (upstream Linux 4.16+ or a PMU-enabled backport)",\n  "glibc_requirement": "GLIBC_%s",\n  "validated_glibc_limit": "GLIBC_2.36",\n  "files": [\n' "$PACKAGE" "$VERSION" "$IGT_VERSION" "$IGT_REVISION" "$GCC_VERSION" "$GLIBC_MAX"
  first=1
  while IFS= read -r file; do
    rel=${file#"$WORK/runtime/"}
    checksum=$(sha256sum "$file" | awk '{print $1}')
    [ "$first" = 1 ] || printf ',\n'
    printf '    {"path":"%s","sha256":"%s"}' "$rel" "$checksum"
    first=0
  done < <(find "$WORK/runtime" -type f | sort)
  printf '\n  ]\n}\n'
} > "$WORK/manifest.json"

mkdir -p "$OUT"
tar -C "$WORK" -czf "$OUT/$NAME.tar.gz" runtime manifest.json
archive_sha=$(sha256sum "$OUT/$NAME.tar.gz" | awk '{print $1}')
printf '{"package":"%s","version":"%s","archive":"%s.tar.gz","sha256":"%s"}\n' \
  "$PACKAGE" "$VERSION" "$NAME" "$archive_sha" > "$OUT/$NAME.manifest.json"
echo "Built $OUT/$NAME.tar.gz"
