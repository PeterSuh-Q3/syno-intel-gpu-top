ARG DSM_VERSION=7.4
FROM dante90/syno-compiler:${DSM_VERSION} AS synology-toolchain

FROM debian:12-slim

# Keep only the Synology cross-toolchains from the compiler image. IGT itself
# is built with native Debian tooling, while final artifacts use /opt/<target>.
COPY --from=synology-toolchain /opt /opt

RUN rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      bison \
      build-essential \
      ca-certificates \
      flex \
      git \
      libglib2.0-dev \
      libjson-c-dev \
      libpciaccess-dev \
      libudev-dev \
      libxml2-dev \
      meson \
      ninja-build \
      pkg-config \
      python3 \
      python3-docutils \
      python3-pip \
      xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
