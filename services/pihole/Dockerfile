FROM pihole/pihole:v5.8.1

WORKDIR /usr/src/app

COPY cont-init.d/ /etc/cont-init.d/

ENV LIGHTTPD_PORT 8080
ENV INTERFACE wlan0
ENV DNSMASQ_LISTENING single
ENV PIHOLE_DNS_ 1.1.1.1;1.0.0.1
ENV WEBPASSWORD balena

ENV DBUS_SYSTEM_BUS_ADDRESS 'unix:path=/host/run/dbus/system_bus_socket'
HEALTHCHECK NONE
