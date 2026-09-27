FROM debian:12-slim

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
