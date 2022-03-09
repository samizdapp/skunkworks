#!/bin/sh

modprobe udp_tunnel
modprobe ip6_udp_tunnel

insmod /wireguard/wireguard.ko || true

exec "$@"