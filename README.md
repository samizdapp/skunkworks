# Skunky

This is some R&D code for the samizdapp project. Very messy, but functional. More docs coming soon. In the meantime, message Ryan with questions.

## Big Picture

This repo contains a proof of concept to configure a raspberry pi or rockpi as a matrix homeserver, accessible via a wireguard VPN, with minimal configuration.

## Getting started

- get a raspberry pi or rockpi
- sign up for a free balena.io account
- set up your SBC for local development, find `<id>.local` for the device
- run `balena push <id>.local`
- wait until command line settles
- reboot device via balena website
- visit `http://<id>.local` from a browser
- use wireguard config to connect with a laptop or phone
- visit `http://local.wg` to access matrix (or use element app with `http://matrix.local.wg` as homeserver)

## What's Going On (Docker Services)

### Wireguard

Wireguard is a point-to-point VPN protocol. Skunky configures a device with two interfaces, one for connections over LAN, and one for WAN (using uPNP to open the wireguard port on the router).

### PiHole

Pihole is an ad-blocking dns server. Skunky runs two instances of it to create a split-horizon DNS setup (allowing client devices to access the device via LAN and WAN without user interaction).

### Matrix

Matrix is a backend service for chat. there are several services in docker-compose.yaml that do different parts of the bootstrap process.

### Element

Element is a web frontend for matrix. Mobile clients will use the matrix app.

### Caddy

Caddy is the webserver in front of everything. when accessed via `<id>.local`, it serves a file browser that has configuration files and QR codes for two wireguard clients.

Everything runs under docker, on a raspberry pi 4 or RockPi 4.
