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
the Synology `/opt` toolchains, and installs IGT build prerequisites on a clean
Debian layer. It does not inherit Mesa, LLVM, Rust, or Cargo from the AMD
runtime builder.

```sh
./scripts/build-builder.sh 7.4
```

This creates the local image `syno-intel-gpu-top-builder:7.4`.
