#!/usr/bin/with-contenv bash
# shellcheck shell=bash

set -e

pihole -a -p "${WEBPASSWORD}" || true

while [ -z "$(ip -o -4 addr show dev "${PIHOLE_INTERFACE}")" ]
do
   echo "Waiting for IPv4 address on ${PIHOLE_INTERFACE}..."
   sleep 5
done

# https://serverfault.com/a/817791
# force dnsmasq to bind only the interfaces it is listening on
# otherwise dnsmasq will fail to start since balena is using 53 on some interfaces
echo "interface=${PIHOLE_INTERFACE}" > /etc/dnsmasq.d/balena.conf
echo "except-interface=lo" >> /etc/dnsmasq.d/balena.conf
echo "listen-address=${PIHOLE_ADDRESS}" >> /etc/dnsmasq.d/balena.conf
echo "bind-interfaces" >> /etc/dnsmasq.d/balena.conf

# declare port for lighttpd
echo "server.port := ${LIGHTTPD_PORT}" > /etc/lighttpd/external.conf

echo "${PIHOLE_ADDRESS} local.wg" > /etc/pihole/custom.list
echo "${PIHOLE_ADDRESS} local.dns" >> /etc/pihole/custom.list
echo "${PIHOLE_ADDRESS} roaming.dns" >> /etc/pihole/custom.list
echo "${PIHOLE_ADDRESS} matrix.local.wg" >> /etc/pihole/custom.list
echo "${PIHOLE_ADDRESS} $HOSTNAME.peertube.wg" >> /etc/pihole/custom.list
echo "${PIHOLE_ADDRESS} local.cacert" >> /etc/pihole/custom.list