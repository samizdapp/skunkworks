# Skunkworks

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

### Wesher

Wesher is a utility for creating fully meshed connected wireguard overlay networks. It's used somewhat abusively here.

Every node generates a uuid based hostname. That hostname starts a wesher mesh for itself in the subnet 10.<first_byte_of_sha1sum_of_hostname>.0.0/16, with wireguard and a control api listening on ports similarly determined by hashing the hostname. we use uPNP to open those ports. joining a peer mesh is accomplished via knowing it's hostname, ip, and a network wide shared key. When a node joins a peer mesh, it's IP is determined as 10.<fbosoh>.<hostname>.<hash>, it's hostname is shared and loaded into the /etc/hosts of all peers, and TLS self-signed certificate are trusted.

The goal is something like this:

- Alice is friends with Bob, Carole, and David. She plugs in her node and goes through setup to access her private admin panel
- Her node starts her mesh network, and opens the necessary ports.
- Alice get's a qr code that she can share with Bob, Carol, and David.
- Bob, Carol, and David scan the qr code with their own management app
- Alice, Bob, Carol, and David's nodes are all fully connected in a p2p vpn, and apps on those nodes can make https requests from each other over the VPN, _without ever needing to talk to ICANN or LetsEncrypt_
  - This is important because most federated protocols require https for server to server communication.

### PeerTube

PeerTube is a video streaming service that runs over ActivityPub. It supports both uploaded video and livestreaming via a browser, and optionally webtorrent as well.
