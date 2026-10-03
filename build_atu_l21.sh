#!/bin/bash
# Build the ATU-L21 kernel used by the Android 12 build (Huawei Y6 2018).
# Needs the GCC 4.9 aarch64 Android toolchain:
#   git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 gcc49
#   git -C gcc49 checkout 961622e   # "Snap for 4667902 ... to pi-release" (the exact toolchain used)
# Usage: CROSS=/path/to/gcc49/bin/aarch64-linux-android- ./build_atu_l21.sh [out-dir]
set -e
OUT=${1:-out}
export ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=${CROSS:?set CROSS to the toolchain prefix}
export KBUILD_BUILD_USER=atu KBUILD_BUILD_HOST=atu-l21
make O=$OUT atu_defconfig
# SELinux permissive support, pstore/ramoops for boot debugging; WireGuard and FORTIFY off (GCC 4.9).
scripts/config --file $OUT/.config \
  --enable SECURITY_SELINUX_DEVELOP --disable WIREGUARD --disable FORTIFY_SOURCE \
  --enable PSTORE --enable PSTORE_CONSOLE --enable PSTORE_PMSG --enable PSTORE_RAM \
  --set-str LOCALVERSION "-atu" --disable LOCALVERSION_AUTO
make O=$OUT olddefconfig
make O=$OUT -j"$(nproc)"
ls -l $OUT/arch/arm64/boot/Image.gz-dtb
