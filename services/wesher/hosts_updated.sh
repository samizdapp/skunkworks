#!/bin/bash

SHA=$(sha1sum <<< "$(cat /etc/hosts)")
touch /etc/hosts.sha
LAST_SHA="$(cat /etc/hosts.sha)"

HOSTFILE="
127.0.0.1       localhost.localdomain           localhost

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
"

if [ "$SHA" == "$LAST_SHA" ]; then
    echo "ignoring own notification"
else
    BANNER="# ! MANAGED AUTOMATICALLY !"
    while read line
    do
        echo $line
        if [[ "$line" == *"$BANNER" ]]; then
            echo $line
            STRINGARRAY=($line)
            IP=${STRINGARRAY[0]}
            HOST=${STRINGARRAY[1]}
            CACERTS="$HOST.cacert"
            PEERTUBE="$HOST.peertube.wg"
            NEWLINE="$IP $HOST $CACERTS $PEERTUBE $BANNER"
            HOSTFILE="$HOSTFILE$NEWLINE"

            curl http://$HOST.cacert/root.crt > /usr/local/share/ca-certificate/$HOST.crt
        fi
    done < /etc/hosts

    update-ca-certificate

    echo "$HOSTFILE" > /etc/hosts.tmp
    (sha1sum <<< "$(cat /etc/hosts.tmp)") > /etc/hosts.sha
    cat /etc/hosts.tmp > /etc/hosts
fi
