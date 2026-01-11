ARG KERNEL_VERSION_ARG=5.4
ARG BUSYBOX_VERSION_ARG=1.36.1

FROM ubuntu:20.04 AS builder

ARG KERNEL_VERSION_ARG
ARG BUSYBOX_VERSION_ARG
ENV KERNEL_VERSION=${KERNEL_VERSION_ARG}
ENV BUSYBOX_VERSION=${BUSYBOX_VERSION_ARG}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential gcc g++ make bc bison flex libssl-dev libelf-dev \
  libncurses-dev libcap-dev libattr1-dev pkg-config \
  dwarves cpio rsync kmod xz-utils bzip2 gnupg2 sudo && \
  rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash builder && \
  echo "builder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder

USER builder
WORKDIR /home/builder

COPY --chown=builder:builder ./downloads/ /home/builder/downloads/
COPY --chown=builder:builder build fs /home/builder/

RUN chmod u+x build && \
  ./build import_gpg_keys && \
  ./build extract_sources && \
  ./build build_all

RUN tar -zcvf linux-${KERNEL_VERSION}.tar.gz -C /home/builder linux-${KERNEL_VERSION} && \
  tar -zcvf busybox-${BUSYBOX_VERSION}.tar.gz -C /home/builder busybox-${BUSYBOX_VERSION}

FROM scratch AS release

ARG KERNEL_VERSION_ARG
ARG BUSYBOX_VERSION_ARG

ENV KERNEL_VERSION=${KERNEL_VERSION_ARG}
ENV BUSYBOX_VERSION=${BUSYBOX_VERSION_ARG}

COPY --from=builder /home/builder/linux-${KERNEL_VERSION}.tar.gz /
COPY --from=builder /home/builder/busybox-${BUSYBOX_VERSION}.tar.gz /
COPY --from=builder /home/builder/fs /fs
