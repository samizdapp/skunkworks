# Change this to armv7hf for the BeagleBone Black
FROM balenalib/amd64-debian:latest-build as builder

RUN install_packages gcc-9 libelf-dev pkg-config flex bison python
WORKDIR /usr/src/app

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

COPY fetch.sh build.sh ./
RUN [ "sh", "fetch.sh" ]
RUN [ "sh", "build.sh" ]

FROM balenalib/amd64-debian


WORKDIR /wireguard
# Copy over any build artifacts that may exist
COPY --from=builder /usr/src/app/output .

RUN install_packages kmod wget wireguard-tools dnsutils qrencode miniupnpc

COPY run.sh /run.sh
COPY install.sh /install.sh

RUN chmod u+x /install.sh /run.sh
ENTRYPOINT [ "/install.sh" ]
CMD [ "/run.sh" ]