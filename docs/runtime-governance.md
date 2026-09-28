# Intel GPU Top runtime governance

## Current source of truth (v0.1.4)

[`syno-intel-gpu-top` v0.1.4](https://github.com/PeterSuh-Q3/syno-intel-gpu-top/releases/tag/v0.1.4)
publishes one native x86_64 `intel_gpu_top` runtime, its private libraries,
and a manifest with per-file SHA-256 hashes. The Debian 12 build does not use
the Synology kvmx64 cross-toolchain. The SPK and runtime filenames do not
encode a DSM platform or kernel flavor. Its shared archive is
`syno-intel-gpu-top-runtime-0.1.4-x86_64.tar.gz` (SHA-256
`46cd5e995193b2224bea1edf4a5960906d4856468b423f38cb4b63e8ad06b4f4`).
The standalone SPK owns the privileged launcher and PATH policy; the shared
runtime archive does not include that launcher.

| Consumer | Current integration |
| --- | --- |
| `mshell-manager` | Remains pinned to the v0.1.3 archive and checks archive plus manifest file hashes before private staging. |
| `syno-gpu-monitor` Intel 0.3.2 | Remains pinned to the v0.1.3 archive and checks archive plus manifest file hashes before private staging. |

Consumers should pin the exact release URL and checksum, verify every file in
the manifest, and preserve the private libraries beside the executable. A
new central runtime requires a new version and an explicit consumer rebuild;
do not overwrite old release assets.

## Kernel and PMU compatibility

Upstream IGT reports Linux 4.16+ as the normal minimum for i915 PMU
telemetry. That is a baseline for an ordinary upstream kernel, not a strict
`uname -r` requirement for a backported DRM stack. The v0.1.3 binary was
verified on DSM 7.4.1 / Linux 5.10.55 and on DSM 7.4.1 / Linux 4.4.302
with the stabilized, Linux 5.4-based i915/PMU backport. The same userspace
binary collected GPU telemetry on both kernels. The backported kernel module
is **not** part of this SPK or runtime archive.

This distinction matters: an unmodified 4.4 i915 driver may lack the PMU
interface, and merely installing the userspace binary cannot add it. With
the stabilized K4 backport, PATH registration and operation have been
validated. The source `postinst` and `postupgrade` hooks register the same
package-owned `/usr/bin/intel_gpu_top` command on K4 and K5; they do not
infer PMU availability from `uname -r`. The executable reports missing DRM/PMU
support when invoked on an unsupported driver. Downstream packages use a
private runtime and manage their own execution policy.

The published v0.1.3 SPK was built before this source-hook cleanup; updating
the repository does not change that immutable release asset. Before claiming
broader package compatibility, verify a newly built SPK, i915 device,
PMU exposure, launcher permissions, and one-shot plus interactive telemetry
on each target. Kernel labels in older v0.1.2 artifacts were packaging labels,
not proof of different executable bytes.
