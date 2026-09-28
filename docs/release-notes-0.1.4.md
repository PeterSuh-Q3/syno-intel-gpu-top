# Synology Intel GPU Top 0.1.4

## English

This release publishes a standalone x86_64 `intel_gpu_top` SPK and a versioned runtime bundle with a per-file SHA-256 manifest for downstream packages.

- The package installation and upgrade hooks now register `/usr/bin/intel_gpu_top` on both K4 and K5; they no longer reject K4 solely by its `uname -r` value.
- The runtime manifest states the actual requirement: an i915 PMU, supplied by an upstream Linux 4.16+ driver or by a PMU-enabled backport.
- The shared runtime is built with Debian 12 native x86_64 GCC; no Synology kvmx64 cross-toolchain or kernel-specific binary is used.
- Existing downstream packages remain pinned to runtime v0.1.3 and do not need rebuilding solely because this release exists.

The v0.1.3 executable was tested on DSM 7.4.1 / Linux 5.10.55 and Linux 4.4.302 with the stabilized Linux 5.4-based i915/PMU backport. The new v0.1.4 SPK passed build, hook, manifest, and package-integrity checks but has not yet been reinstalled on those NAS devices. The K4 PMU-enabled module is a separate prerequisite, not part of this SPK.

SPK SHA-256: `9b8dc4251a2ac57dfa53952dc9adad353f8933c7bc24c5035add5665e5c7a36b`  
Runtime archive SHA-256: `46cd5e995193b2224bea1edf4a5960906d4856468b423f38cb4b63e8ad06b4f4`

## 한국어

독립형 x86_64 `intel_gpu_top` SPK와 파생 패키지용 버전별 런타임 번들·파일별 SHA-256 매니페스트를 제공합니다.

- 설치·업그레이드 훅이 K4와 K5에서 모두 `/usr/bin/intel_gpu_top`을 등록합니다. `uname -r` 값만으로 K4를 배제하지 않습니다.
- 런타임 매니페스트에 실제 요구사항인 i915 PMU를 표기합니다. PMU는 일반적인 Linux 4.16 이상 드라이버 또는 PMU가 활성화된 백포트에서 제공할 수 있습니다.
- Debian 12 네이티브 x86_64 GCC로 공용 런타임을 빌드합니다. Synology kvmx64 교차 툴체인이나 커널별 바이너리는 사용하지 않습니다.
- 기존 파생 패키지는 런타임 v0.1.3에 계속 고정되어 있으므로 이번 릴리즈만으로 재빌드할 필요는 없습니다.

이전 v0.1.3 실행 파일은 DSM 7.4.1의 커널 5.10.55 및 안정화된 Linux 5.4 기반 i915/PMU 백포트를 사용한 커널 4.4.302에서 검증했습니다. 새 v0.1.4 SPK는 빌드·설치 훅·매니페스트·패키지 무결성 검사를 통과했지만 해당 NAS에 재설치하지는 않았습니다. K4용 PMU 활성화 모듈은 이 SPK와 별도로 필요합니다.
