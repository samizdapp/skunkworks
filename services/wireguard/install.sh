#!/bin/sh

modprobe udp_tunnel
modprobe ip6_udp_tunnel

insmod /wireguard/wireguard.ko || true
# ./wesher --cluster-key EAwbL5LelQZGLkMIXCc9vACGFo731UoxiY3oCDJ2/p8= --join 192.168.50.34 --cluster-port 7980 --bind-iface wlan0
# ./wesher --cluster-port 7980 --bind-iface wlan0
exec "$@"