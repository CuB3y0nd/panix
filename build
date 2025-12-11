#!/usr/bin/env bash

set -euo pipefail

KERNEL_VERSION=6.12.61
KERNEL_MIRROR=https://cdn.kernel.org/pub/linux/kernel/v6.x
DIR="linux-$KERNEL_VERSION"
BUSYBOX_VERSION=1.36.1

fetch() {
  local base="$1"
  local file="$2"
  local url="$base/$file"

  if [ -e "$file" ]; then
    echo "[!] Using cached $file"
    return
  fi

  echo "[*] Fetching $file"
  tmp="$file.tmp"
  curl -fSL --etag-save "$file.etag" --output "$tmp" "$url"
  mv "$tmp" "$file"
}

echo "[*] Fetching kernel sources..."
fetch "$KERNEL_MIRROR" "$DIR.tar.xz"
fetch "$KERNEL_MIRROR" "$DIR.tar.sign"

echo "[*] Importing + trusting kernel maintainers' GPG keys..."
gpg2 --locate-keys torvalds@kernel.org gregkh@kernel.org

LINUS_KEY=$(gpg2 --list-keys --with-colons torvalds@kernel.org | awk -F: '/^fpr:/ {print $10; exit}')
GREGKH_KEY=$(gpg2 --list-keys --with-colons gregkh@kernel.org | awk -F: '/^fpr:/ {print $10; exit}')

gpg2 --tofu-policy good "$LINUS_KEY"
gpg2 --tofu-policy good "$GREGKH_KEY"

echo "[*] Verifying kernel tarball..."
xz -cd "$DIR.tar.xz" | gpg2 --trust-model tofu --verify "$DIR.tar.sign" - >/dev/null

if [ ! -d "$DIR" ]; then
  echo "[*] Extracting kernel..."
  tar xf "$DIR.tar.xz"

  echo "[*] Applying kernel patches..."
  sed -i 'N;s/WARN("missing symbol table");\n\t\treturn -1;/\n\t\treturn 0;\n\t\t\/\/ A missing symbol table is actually possible if its an empty .o file.  This can happen for thunk_64.o./g' \
    $DIR/tools/objtool/elf.c
  sed -i 's/unsigned long __force_order/\/\/ unsigned long __force_order/g' \
    $DIR/arch/x86/boot/compressed/pgtable_64.c
fi

echo "[*] Generating defconfig..."
make -C "$DIR" defconfig

echo "[*] Generating scripts..."
make -C "$DIR" scripts

CFG="$DIR/scripts/config"

declare -a configs=(
  CONFIG_NET_9P=y
  CONFIG_NET_9P_DEBUG=n
  CONFIG_9P_FS=y
  CONFIG_9P_FS_POSIX_ACL=y
  CONFIG_9P_FS_SECURITY=y
  CONFIG_NET_9P_VIRTIO=y
  CONFIG_VIRTIO_PCI=y
  CONFIG_VIRTIO_BLK=y
  CONFIG_VIRTIO_BLK_SCSI=y
  CONFIG_VIRTIO_NET=y
  CONFIG_VIRTIO_CONSOLE=y
  CONFIG_HW_RANDOM_VIRTIO=y
  CONFIG_DRM_VIRTIO_GPU=y
  CONFIG_VIRTIO_PCI_LEGACY=y
  CONFIG_VIRTIO_BALLOON=y
  CONFIG_VIRTIO_INPUT=y
  CONFIG_CRYPTO_DEV_VIRTIO=y
  CONFIG_BALLOON_COMPACTION=y
  CONFIG_PCI=y
  CONFIG_PCI_HOST_GENERIC=y
  CONFIG_GDB_SCRIPTS=y
  CONFIG_DEBUG_INFO=y
  CONFIG_DEBUG_INFO_REDUCED=n
  CONFIG_DEBUG_INFO_SPLIT=n
  CONFIG_DEBUG_FS=y
  CONFIG_FRAME_POINTER=y
  CONFIG_DEBUG_INFO_DWARF4=y
  CONFIG_DEBUG_INFO_BTF=y
  CONFIG_DEBUG_INFO_COMPRESSED_NONE=y
  CONFIG_DEBUG_INFO_COMPRESSED_ZLIB=n
  CONFIG_DEBUG_INFO_COMPRESSED_ZSTD=n
  CONFIG_PRINTK=y
  CONFIG_KALLSYMS=y
  CONFIG_KALLSYMS_ALL=y
  CONFIG_MODULES=y
  CONFIG_MODULE_UNLOAD=y
  CONFIG_MODULES_TREE_LOOKUP=y
)

echo "[*] Applying kernel config..."
for item in "${configs[@]}"; do
  key="${item%%=*}"
  val="${item##*=}"
  if [ "$val" = "y" ]; then
    $CFG --enable "$key"
  elif [ "$val" = "n" ]; then
    $CFG --disable "$key"
  else
    $CFG --set-val "$key" "$val"
  fi
done

echo "[*] Finalizing config with olddefconfig..."
make -C "$DIR" olddefconfig

echo "[*] Building kernel..."
make -C "$DIR" -j"$(nproc)" bzImage

echo "[*] Building kernel modules..."
make -C "$DIR" -j"$(nproc)" modules

echo "[*] Installing modules to fs/..."
make -C "$DIR" modules_install INSTALL_MOD_PATH=./fs

fetch "https://busybox.net/downloads" "busybox-$BUSYBOX_VERSION.tar.bz2"

if [ ! -d "busybox-$BUSYBOX_VERSION" ]; then
  echo "[*] Extracting busybox..."
  tar xjf "busybox-$BUSYBOX_VERSION.tar.bz2"
fi

echo "[*] Generating defconfig..."
make -C "busybox-$BUSYBOX_VERSION" defconfig

echo "[*] Applying busybox patches..."
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' \
  busybox-$BUSYBOX_VERSION/.config
# disable tc (fix build errors on modern kernels)
sed -i 's/CONFIG_TC=y/# CONFIG_TC is not set/' \
  busybox-$BUSYBOX_VERSION/.config

echo "[*] Building busybox..."
make -C "busybox-$BUSYBOX_VERSION" -j"$(nproc)"
make -C "busybox-$BUSYBOX_VERSION" install

echo "[*] Building filesystem..."
mkdir -pv fs/{bin,sbin,etc,proc,sys,usr/bin,usr/sbin,root,home/panix}
cp -a "busybox-$BUSYBOX_VERSION/_install/"* fs/

echo "[*] Building LKM modules..."
cd src
make -j"$(nproc)" all
cd ..
cp src/*.ko fs/

echo "[+] Done."
