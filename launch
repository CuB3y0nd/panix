#!/usr/bin/env bash

KERNEL_VERSION=6.12.61

# build root fs

pushd fs || exit
find . -print0 | cpio --null -ov --format=newc | gzip -9 >../initramfs.cpio.gz
popd || exit

# launch

/usr/bin/qemu-system-x86_64 \
  -kernel "linux-$KERNEL_VERSION/arch/x86/boot/bzImage" \
  -initrd "$PWD/initramfs.cpio.gz" \
  -fsdev local,security_model=passthrough,id=fsdev0,path="$HOME" \
  -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
  -nographic \
  -monitor none \
  -s \
  -append "console=ttyS0 nokaslr"
