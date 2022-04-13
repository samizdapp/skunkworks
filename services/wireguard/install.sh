#!/bin/sh

modprobe udp_tunnel
modprobe ip6_udp_tunnel

ls /wireguard

insmod /wireguard/wireguard.ko || true

exec "$@"
