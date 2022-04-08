# Adding Services

In order to figure out what our final stack looks like, we need to be able to rapidly add services to this r&d repo so that we can experience and experiment with various different technologies.

The basic steps to add a new service are:

1. Find or write a docker image(s) for the service
2. add the service(s) to docker-compose.yml
3. Add a DNS record to PiHole in `/services/pihole/cont-init.d`. This allows us to access the service by name through any client device
4. Add server config to Caddyfile in `/services/caddy/Caddyfile`. This allows Caddy to reverse-proxy to the service through a unified interface

# Example: Pleroma

To illustrate the process, let's get Pleroma (a lightweight fediverse server) running.

## Find or write the docker image

Some quick googling will often yeild existing open source code that has dockerized the service you're looking for. In the case of pleroma, we fine [this repo](https://github.com/angristan/docker-pleroma) from @angristan on github. In anticipation of future tweaking, we've [forked it](https://github.com/samizdapp/docker-pleroma).

Then, in `/services` from the command line: `git submodule add https://github.com/samizdapp/docker-pleroma` brings the code into a new folder, `/services/docker-pleroma`

## Add to docker-compose.yml

`docker-pleroma` defines a compose file.

```
version: '3.8'

services:
  db:
    image: postgres:12.1-alpine
    container_name: pleroma_db
    restart: always
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "pleroma"]
    environment:
      POSTGRES_USER: pleroma
      POSTGRES_PASSWORD: ChangeMe!
      POSTGRES_DB: pleroma
    volumes:
      - ./postgres:/var/lib/postgresql/data

  web:
    image: pleroma
    container_name: pleroma_web
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "wget -q --spider --proxy=off localhost:4000 || exit 1",
        ]
    restart: always
    ports:
      - '4000:4000'
    build:
      context: .
      # Feel free to remove or override this section
      # See 'Build-time variables' in README.md
      args:
        - "UID=1000"
        - "GID=1000"
        - "PLEROMA_VER=v2.4.2"
    volumes:
      - ./uploads:/var/lib/pleroma/uploads
      - ./static:/var/lib/pleroma/static
      - ./config.exs:/etc/pleroma/config.exs:ro
    environment:
      DOMAIN: exmaple.com
      INSTANCE_NAME: Pleroma
      ADMIN_EMAIL: admin@example.com
      NOTIFY_EMAIL: notify@example.com
      DB_USER: pleroma
      DB_PASS: ChangeMe!
      DB_NAME: pleroma
    depends_on:
      - db
```

Most of it we can use without changing, but let's take not of two things below.

First, it's got `example.com` as the domain for the web interface. We'll want to pick a name and remember it for subsequent steps. let's pick `pleroma.wg`

Second, it makes use of `bind` mounts directly to the host filesystem. This breaks in the balena case, so when we introduce it into our `docker-compose.yml` we'll want to use volumes instead.

After making these changes, and copying the service definitions to the main `docker-compose.yml` it looks something like this

```

  pleroma_db:
    image: amd64/postgres:12.9-alpine
    container_name: pleroma_db
    restart: always
    environment:
      POSTGRES_USER: pleroma
      POSTGRES_PASSWORD: ChangeMe!
      POSTGRES_DB: pleroma
    volumes:
      - postgres:/var/lib/postgresql/data

  pleroma:
    build: ./services/docker-pleroma/
    image: pleroma
    container_name: pleroma_web
    restart: always
    ports:
      - '4000:4000'
    volumes:
      - uploads:/var/lib/pleroma/uploads
      - static:/var/lib/pleroma/static
    environment:
      DOMAIN: pleroma.wg
      INSTANCE_NAME: Pleroma
      ADMIN_EMAIL: admin@example.com
      NOTIFY_EMAIL: notify@example.com
      DB_USER: pleroma
      DB_PASS: ChangeMe!
      DB_NAME: pleroma
      DB_HOST: pleroma_db
    depends_on:
      - pleroma_db
```

## Add DNS record to PiHole

Now we'll have a pleroma server running that we can access via `localhost:4000`, but we want to be able to access it via any clients connecting via the VPN, so let's go to `/services/pihole/cont-init.d/10-custom.sh` and take a look at the bootom of the file:

```
echo "${PIHOLE_ADDRESS} local.wg" > /etc/pihole/custom.list
echo "${PIHOLE_ADDRESS} local.dns" >> /etc/pihole/custom.list
echo "${PIHOLE_ADDRESS} roaming.dns" >> /etc/pihole/custom.list
echo "${PIHOLE_ADDRESS} bootstrap.local" >> /etc/pihole/custom.list
echo "${PIHOLE_ADDRESS} local.cacert" >> /etc/pihole/custom.list
```

simply add another echo line with the chosen domain name for the new service:

```
echo "${PIHOLE_ADDRESS} peertube" >> /etc/pihole/custom.list
```

Now a client connected to the wireguard vpn will be able to resolve `plerome.wg` to the docker server

## Add server config to Caddyfile

Caddy acts as a reverse-proxy to any other services, and abstracts away tls management. `/services/caddy/Caddyfile` contains the basic configuration. Different projects may need different levels of config here, but pleroma is rather simple, all we have to do is add a basic config block for our new domain, and configure the reverse proxy to point to our pleroma server:

```
pleroma.wg {
    reverse_proxy localhost:4000 {
        header_up Host {upstream_hostport}
    }
}
```

## Fin

if all went well, rerunning `docker-compose up --build` in the root of the project will now allow a client to visit `https://pleroma.wg` in a web browser and access the server! (note, you'll have to click through the "unsafe website" warnings for the time being)

There are of course unsolved problems about getting federation to work over the VPN and bootstrapping all the node-to-node networking, but those are out of scope for the purposes of this tutorial.
