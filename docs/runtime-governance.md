# Intel GPU Top runtime governance

Status: native x86_64 build implemented for v0.1.3, 2026-09-27. This document
defines a single, centrally published `intel_gpu_top` userspace runtime for
downstream packages. It does not authorize a K4 compatibility claim.

## Findings from the current source and artifacts

- `intel_gpu_top` is an x86_64 userspace executable, not a kernel module. The
  v0.1.3 build path uses Debian 12's native x86_64 compiler; it does not
  download or invoke the Synology `kvmx64` toolchain. No kernel headers or
  kernel-flavor-specific compile flags are used.
- Before v0.1.3, `KERNEL_FLAVOR` changed the staged marker, package
  description, output filename, and runtime manifest without changing the
  compiled `intel_gpu_top` or target dependency inputs. Thus the old K4/K5
  labels did not establish distinct binaries or kernel compatibility.
- The pinned IGT v2.5 source explicitly reports that i915 PMU monitoring
  requires Linux kernel 4.16 or newer (`tools/intel_gpu_top.c`, around line
  2770). DSM 4.4.302 is below this minimum; a second K4 binary cannot add the
  missing kernel PMU interface. K4 should therefore be documented as
  unsupported for useful `intel_gpu_top` telemetry, not as a separate runtime
  flavor.
- The published v0.1.2 runtime bundle is
  `syno-intel-gpu-top-runtime-0.1.2-x86_64-kernel5.10.55.tar.gz`, SHA-256
  `98041f2e93ba17f99eabc2c31a6a676dfb59e25fdac87f1651e54f49ac8a5928`.
  Its embedded manifest gives `intel_gpu_top.real` SHA-256
  `bb38d0c83d6193b018980037ccaf9cd50a0ec7b60ae65e64e23d744d1c774d25`.
  It bundles private `libpci` and `libudev`; the embedded runtime deliberately
  excludes the SPK-specific privileged launcher.
- The inspected executable is x86-64 PIE with `$ORIGIN/../lib` RPATH and
  depends on `libpci.so.3`, `libudev.so.1`, and DSM's `libc.so.6`. Its highest
  observed glibc symbol requirement is `GLIBC_2.33`. It was built using GCC
  12.2.0 from the Synology kvmx64 toolchain whose sysroot is glibc 2.36.
  This is evidence for a single x86_64 userspace build, but not yet proof that
  any arbitrary host compiler produces a DSM-compatible ELF.

## Target policy

1. Publish one architecture-level runtime per source/package version:
   `syno-intel-gpu-top-runtime-<version>-x86_64.tar.gz`. Do not include
   `kernel4`, `kernel5`, `kvmx64`, or DSM version in runtime filenames.
2. Build and hash the real executable once. Any standalone SPK and downstream
   bundle for that release must consume those exact bytes and the same private
   libraries. Keep the setuid launcher out of the shared runtime archive; only
   the standalone SPK owns PATH registration and privileged execution policy.
3. The manifest records package version, x86_64 architecture, IGT version and
   pinned commit, compiler/builder identity, required glibc symbol baseline,
   each runtime file's SHA-256, and the minimum i915 PMU kernel requirement
   (4.16). It does not claim K4/K5 binary variants.
4. Supported monitoring policy is DSM kernel 5.10.55 with a working i915 DRM
   device, i915 PMU exposure, and sufficient `perf_event_open` privileges.
   Kernel 4.4.302 is not a supported telemetry target. The product may retain
   one universal SPK if needed for package distribution, but on K4 it must not
   install a misleading PATH shim or claim the monitor works.
5. Keep userspace package versioning independent of kernel labels. Issue one
   new release version when the runtime, packaging, or manifest changes; do not
   rebuild/release identical payloads as separate K4 and K5 versions.

## Native compiler policy

The `kvmx64` Synology cross-compiler has been removed from the build image and
scripts. Debian 12 native x86_64 GCC is used, while `create-runtime-bundle.sh`
rejects ELF files whose highest glibc symbol exceeds 2.36. This ABI gate is a
build-time compatibility check, not a substitute for testing the exact SPK on
a DSM 7.4 Intel-iGPU system (CLI help, one-shot JSON, and interactive TUI under
the package helper). The package's `arch` metadata may still list `kvmx64`:
that is an install-architecture declaration, not use of the kvmx64 compiler.

## Downstream consumers and migration

The local consumers found during this audit are:

- `syno-gpu-monitor/intel/scripts/build-spk.sh`, which downloads the v0.1.2
  K5-named runtime and checks its SHA-256.
- `mshell-manager/build-spk.sh`, which embeds the v0.1.2 K5-named archive;
  its release workflow verifies the expected embedded runtime path.
- `mshell-manager` telemetry/console code, which consumes the real binary from
  its private `gpu-runtime/intel` location.

After publishing the first unified runtime, migrate each consumer separately
to the exact new release URL and archive checksum. Each consumer should also
verify the embedded per-file manifest, preserve the private libraries, and
gate the console/fallback on actual i915 PMU availability rather than selecting
a K4/K5 binary by `uname`. Keep the existing v0.1.2 assets immutable for old
consumer builds; do not overwrite them during migration.

## Release validation checklist

- Build the x86_64 runtime once from the pinned IGT revision.
- Audit `file`, `readelf -d`, and `readelf --version-info`; reject unexpected
  dependencies, host paths, or a glibc requirement newer than the declared
  DSM baseline.
- Verify archive and individual-file hashes against the manifest.
- Validate on DSM K5 with a real Intel i915 device and PMU access.
- On DSM K4, make no success claim; confirm only that package behavior is
  explicit and does not create a misleading global command.
- Update downstream repositories to one pinned runtime release and verify
  their packaged bytes against the central manifest before publishing.
