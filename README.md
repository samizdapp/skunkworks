# Skunkworks

This is some R&D code for the samizdapp project. Very messy, but functional. More docs coming soon. In the meantime, message Ryan with questions.

## Big Picture

This repo contains bare minimum setup to configure a dev environment or raspberry/rock pi into a wireguard VPN server and split tunnel DNS server via PiHole. Additionally, it contains a boneyard of other dockerized services.

## Getting started (Docker)

Prerequisits: [docker, docker-compose](https://docs.docker.com/compose/install/), and [wireguard](https://www.wireguard.com/install/) for your development machine and optionally a phone.

- run the `install.sh` script, this will start two wireguard interfaces and generate two client configurations
- visit http://localhost to download client configuration `client1.conf`
- from a terminal, run `wg-quick up ./client1.conf`
- visit http://local.dns and http://roaming.dns to view the web interfaces for the two PiHole instances
- go back to http://localhost and view `client2.png`
- scan the qr code with your mobile wireguard client
- activate the vpn and try to visit http://local.dns and http://roaming.dns from your phone (try turning off WiFi too to demonstrate roaming)

At this point, you now have a roaming capable tunnel to your dev environment, and can start hacking on other services.

## Getting started (Hardware)

Note: there are some magic strings in wireguard/Dockerfile and caddy/dockerfile. these need to be made configurable, but for now, change `amd64` to `aarch64` in all base image declarations, and uncomment the appropriate blocks in `wireguard/Dockerfile` depending on platform.

- get a raspberry pi or rockpi
- sign up for a free balena.io account
- set up your SBC for local development, find `<id>.local` for the device
- run `balena push <id>.local`
- wait until command line settles
- reboot device via balena website
- visit http://<id>.local to download client configuration `client1.conf`
- from a terminal, run `wg-quick up ./client1.conf`
- visit http://local.dns and http://roaming.dns to view the web interfaces for the two PiHole instances
- go back to http://localhost and view `client2.png`
- scan the qr code with your mobile wireguard client
- activate the vpn and try to visit http://local.dns and http://roaming.dns from your phone (try turning off WiFi too to demonstrate roaming)

At this point, you now have a roaming capable tunnel to your hardware environment, and can start hacking on services

### Hacking Services

Coming soon
