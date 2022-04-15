#1/bin/bash

# This is a bit of a hack, eventually we're going to run into a port collision
WESHER_WG_SUB=$(sha1sum <<<$(hostname)|cut -c1-4)
WESHER_WG_PORT=$((0x$(sha1sum <<<$(hostname)|cut -c1-3)0))
WESHER_CONTROL_PORT=$((0x$(sha1sum <<<$WESHER_WG_PORT|cut -c1-3)0))
WESHER_IFACE="overlay$(hostname)"
BIND_IFACE=$(route | grep '^default' | grep -o '[^ ]*$')
# https://superuser.com/a/1403037
BIND_ADDR=$(ip -6 addr|awk '{print $2}'|grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64'|cut -d '/' -f1 | head -1)
WAN_ADDR=$(dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"')
LAN_ADDR=$(upnpc -l | grep "Local LAN ip address" | cut -d: -f2)

upnpc -r $WESHER_WG_PORT UDP
upnpc -r $WESHER_CONTROL_PORT UDP
upnpc -r $WESHER_CONTROL_PORT TCP

mkdir -p /var/lib/wesher
if [ ! -f /var/lib/wesher/cluster.key ]
then
echo "$(head -c 32 /dev/random | base64)" > /var/lib/wesher/cluster.key
fi

CLUSTER_KEY=$(cat /var/lib/wesher/cluster.key)

./watch_hosts.sh & jobs

LAN_JOIN_COMMAND="./wesher --cluster-port $WESHER_CONTROL_PORT --wireguard-port $WESHER_WG_PORT --overlay-net fe80:$WESHER_WG_SUB::/32 --interface $WESHER_IFACE --join $LAN_ADDR --cluster-key $CLUSTER_KEY"
echo $LAN_JOIN_COMMAND
echo "#!/bin/bash" > /var/lib/wesher/lan_invite.sh
echo $LAN_JOIN_COMMAND >> /var/lib/wesher/lan_invite.sh

WAN_JOIN_COMMAND="./wesher --cluster-port $WESHER_CONTROL_PORT --wireguard-port $WESHER_WG_PORT --overlay-net fe80:$WESHER_WG_SUB::/32 --interface $WESHER_IFACE --join $WAN_ADDR --cluster-key $CLUSTER_KEY"
echo $WAN_JOIN_COMMAND
echo "#!/bin/bash" > /var/lib/wesher/wan_invite.sh
echo $WAN_JOIN_COMMAND >> /var/lib/wesher/wan_invite.sh


chmod +x /var/lib/wesher/lan_invite.sh
chmod +x /var/lib/wesher/wan_invite.sh

./wesher --init true --cluster-port $WESHER_CONTROL_PORT --wireguard-port $WESHER_WG_PORT --overlay-net fe80:$WESHER_WG_SUB::/32 --interface $WESHER_IFACE --log-level debug --cluster-key $CLUSTER_KEY --bind-addr $BIND_ADDR
