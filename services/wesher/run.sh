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

echo "./wesher --cluster-port $WESHER_CONTROL_PORT --wireguard-port $WESHER_WG_PORT --interface $WESHER_IFACE --bind-iface wlan0 --join $lan --cluster-key"

./watch_hosts.sh & jobs

./wesher --init true --cluster-port $WESHER_CONTROL_PORT --wireguard-port $WESHER_WG_PORT --overlay-net 10.$WESHER_WG_SUB.0.0/16 --interface $WESHER_IFACE --bind-iface wlan0

# CLUSTER_KEY=$(grep ClusterKey /var/lib/wesher/state.json)
# echo "CREATED NEW CLUSTER $CLUSTER_KEY"