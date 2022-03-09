#1/bin/bash

# This is a bit of a hack, eventually we're going to run into a port collision
WESHER_WG_PORT=$((0x$(sha1sum <<<$(hostname)|cut -c1-3)0))
WESHER_CONTROL_PORT=$((0x$(sha1sum <<<$WESHER_WG_PORT|cut -c1-3)0))
WESHER_IFACE="overlay$(hostname)"

upnpc -r $WESHER_WG_PORT UDP
upnpc -r $WESHER_CONTROL_PORT UDP
upnpc -r $WESHER_CONTROL_PORT TCP

./wesher --cluster-port $WESHER_CONTROL_PORT --wireguard-port $WESHER_WG_PORT --interface $WESHER_IFACE --bind-iface wlan0

exec balena-idle