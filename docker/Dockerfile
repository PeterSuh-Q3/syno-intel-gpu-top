ARG DSM_VERSION=7.4
FROM dante90/syno-compiler:${DSM_VERSION} AS synology-toolchain

FROM debian:12-slim

# intel_gpu_top is a portable x86_64 userspace tool. Keep only the representative
# kvmx64 Synology toolchain rather than copying every platform under /opt.
# This avoids a multi-gigabyte duplicate toolchain layer in Docker Desktop.
COPY --from=synology-toolchain /opt/kvmx64 /opt/kvmx64

RUN rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      bison \
      build-essential \
      ca-certificates \
      flex \
      gperf \
      git \
      libglib2.0-dev \
      libdrm-dev \
      libdw-dev \
      libjson-c-dev \
      libkmod-dev \
      libpciaccess-dev \
      libpci-dev \
      libpixman-1-dev \
      libcairo2-dev \
      libudev-dev \
      libxml2-dev \
      libtool \
      meson \
      ninja-build \
      pkg-config \
      python3 \
      python3-docutils \
      python3-pip \
      xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
