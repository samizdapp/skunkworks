# Change this to armv7hf for the BeagleBone Black
FROM balenalib/amd64-debian:latest-build as builder

RUN install_packages gcc-9 libelf-dev pkg-config flex bison python
WORKDIR /usr/src/app

RUN git clone https://git.zx2c4.com/wireguard-linux-compat && \
    git clone https://git.zx2c4.com/wireguard-tools

# for raspberry pi
# ENV VERSION '2.88.4.dev'
# ENV BALENA_MACHINE_NAME 'raspberrypi4-64'

# for rockpi
# ENV VERSION '2.83.10+rev1.dev'
# ENV BALENA_MACHINE_NAME 'rockpi-4b-rk3399'

# for beaglebone-black
# ENV VERSION '2.85.16+rev1.dev'
# ENV BALENA_MACHINE_NAME 'beaglebone-black'

# docker
ENV VERSION '2.83.18+rev1.dev'
ENV BALENA_MACHINE_NAME 'genericx86-64-ext'

RUN curl -L https://files.balena-cloud.com/images/$BALENA_MACHINE_NAME/$(echo $VERSION | sed s/+/%2B/)/kernel_modules_headers.tar.gz | tar xz

# Download missing header(s) https://forums.balena.io/t/build-kernel-module-out-of-tree-for-jetson/295852/22
# This is required on some devices like the RockPi 4B
RUN HYPERVISOR_HEADER=kernel_modules_headers/arch/arm/include/asm/xen/hypervisor.h && \
    if [ ! -f $HYPERVISOR_HEADER ]; then \
        mkdir -p $(dirname $HYPERVISOR_HEADER) && \
        curl -SsL -o $HYPERVISOR_HEADER \
        https://raw.githubusercontent.com/OE4T/linux-tegra-4.9/oe4t-patches-l4t-r32.6/arch/arm/include/asm/xen/hypervisor.h; \
    fi

RUN ln -s /lib64/ld-linux-arm64.so.2  /lib/ld-linux-arm64.so.2 || true
RUN ln -s /lib64/ld-linux-x86-64.so.2  /lib/ld-linux-x86-64.so.2 || true

# https://github.com/Tomoms/android_kernel_oppo_msm8974/commit/11647f99b4de6bc460e106e876f72fc7af3e54a6.patch
# RUN sed -i '/YYLTYPE/d' ./kernel_modules_headers/scripts/dtc/dtc-lexer.lex.c
RUN echo 'CFLAGS_main.o := -Wno-missing-attributes' >> ./wireguard-linux-compat/src/KBuild

RUN make -C kernel_modules_headers -j$(nproc) modules_prepare
RUN make CC=gcc-9 -C kernel_modules_headers M=$(pwd)/wireguard-linux-compat/src -j$(nproc) || true
RUN make -C $(pwd)/wireguard-tools/src -j$(nproc) && \
    mkdir -p $(pwd)/tools && \
    make -C $(pwd)/wireguard-tools/src DESTDIR=$(pwd)/tools install

FROM balenalib/amd64-debian


WORKDIR /wireguard
# COPY --from=builder /usr/src/app/wireguard-linux-compat/src/wireguard.ko .
COPY --from=builder /usr/src/app/tools .

RUN install_packages kmod wget wireguard-tools dnsutils qrencode miniupnpc

COPY run.sh /run.sh
COPY install.sh /install.sh

RUN chmod u+x /install.sh /run.sh
ENTRYPOINT [ "/install.sh" ]
CMD [ "/run.sh" ]