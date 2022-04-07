set -ve
mkdir output

# Abort building wireguard for this kernel if it is already included
KERNEL_RELEASE=$(cat kernel_modules_headers/include/config/kernel.release)
dpkg --compare-versions $KERNEL_RELEASE ge 5.6 && exit 0

git clone https://git.zx2c4.com/wireguard-linux-compat
git clone https://git.zx2c4.com/wireguard-tools

# Download missing header(s) https://forums.balena.io/t/build-kernel-module-out-of-tree-for-jetson/295852/22
# This is required on some devices like the RockPi 4B
HYPERVISOR_HEADER=kernel_modules_headers/arch/arm/include/asm/xen/hypervisor.h
if [ ! -f $HYPERVISOR_HEADER ]; then
    mkdir -p $(dirname $HYPERVISOR_HEADER)
    curl -SsL -o $HYPERVISOR_HEADER
    https://raw.githubusercontent.com/OE4T/linux-tegra-4.9/oe4t-patches-l4t-r32.6/arch/arm/include/asm/xen/hypervisor.h
fi

ln -s /lib64/ld-linux-arm64.so.2  /lib/ld-linux-arm64.so.2 || true
ln -s /lib64/ld-linux-x86-64.so.2  /lib/ld-linux-x86-64.so.2 || true

# https://github.com/Tomoms/android_kernel_oppo_msm8974/commit/11647f99b4de6bc460e106e876f72fc7af3e54a6.patch
# RUN sed -i '/YYLTYPE/d' ./kernel_modules_headers/scripts/dtc/dtc-lexer.lex.c
echo 'CFLAGS_main.o := -Wno-missing-attributes' >> ./wireguard-linux-compat/src/KBuild

make CC=gcc-9 -C kernel_modules_headers M=wireguard-linux-compat/src -j$(nproc) && \
    mv wireguard-linux-compat/src/wireguard.ko output
make -C $(pwd)/wireguard-tools/src -j$(nproc) && \
    mkdir -p $(pwd)/tools && \
    make -C $(pwd)/wireguard-tools/src DESTDIR=output install
