#!/bin/bash
grep -qxF '100 wgone' /etc/iproute2/rt_tables || echo '100 wgone' >> /etc/iproute2/rt_tables
grep -qxF '200 wgtwo' /etc/iproute2/rt_tables || echo '200 wgtwo' >> /etc/iproute2/rt_tables

export LC_ALL=C
router=$(ip r | grep default | cut -d " " -f 3)
gateway=$(upnpc -l | grep "desc: http://$router:[0-9]*/rootDesc.xml" | cut -d " " -f 3)
lan=$(upnpc -l | grep "Local LAN ip address" | cut -d: -f2)
wan=$(dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"')

WGONE_PRIV=$(wg genkey)
WGTWO_PRIV=$(wg genkey)
CLIENT1_PRIV=$(wg genkey)
CLIENT2_PRIV=$(wg genkey)

WGONE_PUB=$(echo $WGONE_PRIV | wg pubkey)
WGTWO_PUB=$(echo $WGTWO_PRIV | wg pubkey)
CLIENT1_PUB=$(echo $CLIENT1_PRIV | wg pubkey)
CLIENT2_PUB=$(echo $CLIENT2_PRIV | wg pubkey)

port=51822
upnpc -a $lan $port $port UDP

if [ ! -f /wireguard/wgone.conf ]
then


echo "
[Interface]
Address = 10.128.0.10/31
PrivateKey = $CLIENT1_PRIV
DNS = 10.128.0.1,10.128.0.2

[Peer]
PublicKey = $WGONE_PUB
AllowedIPs = 10.128.0.1/32
Endpoint= $lan:51821

[Peer]
PublicKey = $WGTWO_PUB
AllowedIPs = 10.128.0.2/32
Endpoint= $wan:$port
" > /wireguard/client1.conf

echo "
[Interface]
Address = 10.128.0.12/31
PrivateKey = $CLIENT2_PRIV
DNS = 10.128.0.1,10.128.0.2

[Peer]
PublicKey = $WGONE_PUB
AllowedIPs = 10.128.0.1/32
Endpoint= $lan:51821

[Peer]
PublicKey = $WGTWO_PUB
AllowedIPs = 10.128.0.2/32
Endpoint= $wan:$port
" > /wireguard/client2.conf

qrencode -r /wireguard/client1.conf -o /wireguard/client1.png
qrencode -r /wireguard/client2.conf -o /wireguard/client2.png

echo "
[Interface]
Address = 10.128.0.1/32
ListenPort = 51821
PrivateKey = $WGONE_PRIV
Table = wgone
PostUp = ip rule add from 10.128.0.1 table wgone prio 1 

[Peer]
PublicKey = $CLIENT1_PUB
AllowedIPs = 10.128.0.10/32

[Peer]
PublicKey = $CLIENT2_PUB
AllowedIPs = 10.128.0.12/32
" > /wireguard/wgone.conf

echo "
[Interface]
Address = 10.128.0.2/32
ListenPort = $port
PrivateKey = $WGTWO_PRIV
Table = wgtwo
PostUp = ip rule add from 10.128.0.2 table wgtwo prio 2

[Peer]
PublicKey = $CLIENT1_PUB
AllowedIPs = 10.128.0.10/32

[Peer]
PublicKey = $CLIENT2_PUB
AllowedIPs = 10.128.0.12/32
" > /wireguard/wgtwo.conf

fi

ip rule del from 10.128.0.2
ip rule del from 10.128.0.1
wg-quick down /wireguard/wgone.conf
wg-quick down /wireguard/wgtwo.conf
wg-quick up /wireguard/wgone.conf
wg-quick up /wireguard/wgtwo.conf
