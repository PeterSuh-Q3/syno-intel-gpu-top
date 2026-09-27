# syno-intel-gpu-top

Standalone `intel_gpu_top` SPK for Synology DSM.

The package will build the upstream IGT `intel_gpu_top` utility and ship only
its minimum runtime dependencies. It is separate from the DSM GPU Monitor UI:
this repository provides the interactive CLI, JSON, CSV, and periodic-output
modes used for direct diagnostics.

## Runtime policy

- DSM kernel 5.10 with an i915 PMU is the supported profile.
- The package exposes a narrow DSM-managed setuid launcher because i915
  system-wide PMU counters require privileged `perf_event_open` access on DSM.
- The launcher will allow only display and sampling arguments. Root file-output
  options are deliberately excluded.
- IGT's `intel_gpu_top` requires Linux 4.16+ for i915 PMU telemetry. DSM
  kernel 4.4.302 is not a supported telemetry target; no K4-specific binary
  flavor is built.

## Builder

The builder uses Debian 12's native x86_64 GCC and does not download or use a
Synology platform toolchain. The runtime ABI is checked against the DSM 7.4
glibc 2.36 baseline before creating the runtime bundle. It does not inherit
Mesa, LLVM, Rust, or Cargo from the AMD runtime builder.

```sh
./scripts/build-builder.sh
```

This creates the local image `dante90/syno-intel-gpu-top-builder:debian12-native`.

Each build creates one `syno-intel-gpu-top-<version>-x86_64.spk` and one
`syno-intel-gpu-top-runtime-<version>-x86_64.tar.gz`, plus a checksum sidecar
and per-file manifest in `dist/`. The runtime bundle contains
`intel_gpu_top.real` and its private `libpci`/`libudev` libraries. The
SPK-only privileged launcher is deliberately excluded.

## Build

```sh
./scripts/fetch-sources.sh
./scripts/build-builder.sh
COMPILE_JOBS=12 ./scripts/run-spk-build.sh
```

The native x86_64 dependency prefix is built separately and bundled below the
package's own `target/` directory. DSM libraries and graphics drivers are
never overwritten. Intel Xe is outside upstream `intel_gpu_top` support.

The package is intentionally daemonless. Package Center can show it as
stopped because there is no background service to run; the `intel_gpu_top`
command remains available after installation. On kernel 5.10.55 its PATH shim
is installed even before an Intel DRM device is present.

## License

The Synology SPK packaging, build scripts, and DSM integration in this
repository are licensed under the [MIT License](LICENSE).

The resulting package builds and bundles upstream third-party components,
including IGT's `intel_gpu_top`, libdrm, eudev, and pciutils. Those components
remain subject to their respective upstream licenses; this repository's MIT
license does not replace or supersede their notices or terms. IGT's pinned
source revision and its original `COPYING` file are recorded in
[`build/sources.lock`](build/sources.lock).
