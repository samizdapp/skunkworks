FROM balenalib/aarch64-debian as builder

RUN install_packages curl gcc-9 g++-9 build-essential libelf-dev libssl-dev pkg-config git flex bison python
RUN sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9
WORKDIR /usr/src/app

RUN git clone https://git.zx2c4.com/wireguard-linux-compat && \
    git clone https://git.zx2c4.com/wireguard-tools

# for raspberry pi
# ENV VERSION '2.88.4.dev'
# ENV BALENA_MACHINE_NAME 'raspberrypi4-64'
# for rockpi

ENV VERSION '2.83.10+rev1.dev'
ENV BALENA_MACHINE_NAME 'rockpi-4b-rk3399'

RUN curl -L -o headers.tar.gz $(echo "https://files.balena-cloud.com/images/$BALENA_MACHINE_NAME/$VERSION/kernel_modules_headers.tar.gz" | sed -e 's/+/%2B/') && \
    tar -xf headers.tar.gz

# Download missing header(s) https://forums.balena.io/t/build-kernel-module-out-of-tree-for-jetson/295852/22
RUN mkdir -p kernel_modules_headers/arch/arm/include/asm/xen && \
    curl -SsL -o kernel_modules_headers/arch/arm/include/asm/xen/hypervisor.h \
    https://raw.githubusercontent.com/OE4T/linux-tegra-4.9/oe4t-patches-l4t-r32.6/arch/arm/include/asm/xen/hypervisor.h


RUN ln -s /lib64/ld-linux-arm64.so.2  /lib/ld-linux-arm64.so.2 || true

# https://github.com/Tomoms/android_kernel_oppo_msm8974/commit/11647f99b4de6bc460e106e876f72fc7af3e54a6.patch
RUN sed -i '/YYLTYPE/d' ./kernel_modules_headers/scripts/dtc/dtc-lexer.lex.c
RUN echo 'CFLAGS_main.o := -Wno-missing-attributes' >> ./wireguard-linux-compat/src/KBuild
RUN which gcc

RUN make -C kernel_modules_headers -j$(nproc) modules_prepare
RUN make CC=gcc-9 -C kernel_modules_headers M=$(pwd)/wireguard-linux-compat/src -j$(nproc) 
RUN make -C $(pwd)/wireguard-tools/src -j$(nproc) && \
    mkdir -p $(pwd)/tools && \
    make -C $(pwd)/wireguard-tools/src DESTDIR=$(pwd)/tools install

FROM balenalib/aarch64-debian


WORKDIR /wireguard
COPY --from=builder /usr/src/app/wireguard-linux-compat/src/wireguard.ko .
COPY --from=builder /usr/src/app/tools .

RUN install_packages kmod wget wireguard-tools dnsutils qrencode miniupnpc

COPY run.sh /run.sh
COPY install.sh /install.sh

RUN chmod u+x /install.sh /run.sh
ENTRYPOINT [ "/install.sh" ]
CMD [ "/run.sh" ]