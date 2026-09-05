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
- Kernel 4.4 builds, if published, will be diagnostic/experimental and will
  not register a global PATH command automatically.

## Builder

The lightweight builder starts with `dante90/syno-compiler:7.4`, copies only
the representative `/opt/kvmx64` Synology toolchain, and installs IGT build
prerequisites on a clean Debian layer. It does not inherit Mesa, LLVM, Rust,
or Cargo from the AMD runtime builder.

```sh
./scripts/build-builder.sh 7.4
```

This creates the Docker Hub-tagged image `dante90/syno-intel-gpu-top-builder:7.4`.

Each build also creates `syno-intel-gpu-top-runtime-*-kernel5.10.55.tar.gz` and a sidecar `*.manifest.json` in `dist/`.  The runtime bundle is for controlled Manager embedding: it contains `intel_gpu_top.real`, its private `libpci`/`libudev` libraries, and archive/file SHA-256 verification data. The SPK-only privileged launcher is deliberately excluded.

## Build

```sh
./scripts/fetch-sources.sh
./scripts/build-builder.sh 7.4
COMPILE_JOBS=12 ./scripts/run-spk-build.sh kvmx64 7.4 kernel5.10.55
```

The target dependency prefix is built separately and bundled below the
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
