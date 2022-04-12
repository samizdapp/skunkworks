#1/bin/bash

# This is a bit of a hack, eventually we're going to run into a port collision
WESHER_WG_SUB=$((0x$(sha1sum <<<$(hostname)|cut -c1-1)0))
WESHER_WG_PORT=$((0x$(sha1sum <<<$(hostname)|cut -c1-3)0))
WESHER_CONTROL_PORT=$((0x$(sha1sum <<<$WESHER_WG_PORT|cut -c1-3)0))
WESHER_IFACE="overlay$(hostname)"
wan=$(dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"')
lan=$(upnpc -l | grep "Local LAN ip address" | cut -d: -f2)

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

JOIN_COMMAND="./wesher --cluster-port $WESHER_CONTROL_PORT --wireguard-port $WESHER_WG_PORT --interface $WESHER_IFACE --join $lan --cluster-key $CLUSTER_KEY"
echo $JOIN_COMMAND

./wesher --cluster-port $WESHER_CONTROL_PORT --wireguard-port $WESHER_WG_PORT --overlay-net 10.$WESHER_WG_SUB.0.0/16 --interface $WESHER_IFACE --log-level debug --cluster-key $CLUSTER_KEY
