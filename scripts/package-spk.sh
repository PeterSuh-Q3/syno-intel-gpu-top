#!/usr/bin/env bash
set -euo pipefail
STAGE=${1:?staging root required}
KERNEL_FLAVOR=${2:-kernel5.10.55}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
PACKAGE=syno-intel-gpu-top
ASSEMBLY="$ROOT/work/spk-${KERNEL_FLAVOR}"
OUT="$ROOT/dist"
case "$KERNEL_FLAVOR" in kernel5.10.55|kernel4.4.x) ;; *) echo 'unsupported kernel flavor' >&2; exit 2;; esac
rm -rf "$ASSEMBLY"
mkdir -p "$ASSEMBLY/scripts" "$ASSEMBLY/conf"
cp "$ROOT/spk/INFO" "$ASSEMBLY/INFO"
cp "$ROOT/spk/scripts/"* "$ASSEMBLY/scripts/"
cp "$ROOT/spk/conf/"* "$ASSEMBLY/conf/"
if [ "$KERNEL_FLAVOR" = kernel4.4.x ]; then
  sed -i -E 's#^description=".*"$#description="Standalone Intel i915 GPU monitor for DSM (kernel 4.4 diagnostic build)."#' "$ASSEMBLY/INFO"
fi
for icon in PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG; do cp "$ROOT/spk/$icon" "$ASSEMBLY/$icon"; done
tar -C "$STAGE/var/packages/$PACKAGE/target" -czf "$ASSEMBLY/package.tgz" .
checksum=$(md5sum "$ASSEMBLY/package.tgz" | awk '{print $1}')
extractsize=$(du -sk "$STAGE/var/packages/$PACKAGE" | awk '{print $1}')
printf 'extractsize="%s"\ncreate_time="%s"\nchecksum="%s"\n' "$extractsize" "$(date +%Y%m%d-%H:%M:%S)" "$checksum" >> "$ASSEMBLY/INFO"
mkdir -p "$OUT"
VERSION=$(sed -n 's/^version="\([^"]*\)"$/\1/p' "$ASSEMBLY/INFO" | head -n 1)
tar -C "$ASSEMBLY" -cf "$OUT/${PACKAGE}-${VERSION}-x86_64-${KERNEL_FLAVOR}.spk" INFO package.tgz scripts conf PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG
