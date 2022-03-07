#!/bin/bash
while [ ! -f /data/homeserver.yaml ]
do
  sleep 2 # or less like 0.2
done
sleep 2

grep -qxF 'enable_registration: true' /data/homeserver.yaml || echo 'enable_registration: true' >> /data/homeserver.yaml

exec balena-idle