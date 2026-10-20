# WireGuard

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-wireguard) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fwireguard) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fwireguard) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-wireguard/dev.yml?branch=main)

[Docker Hub](https://hub.docker.com/r/bfren/wireguard) - [Quay.io](https://quay.io/repository/bfren/wireguard) - [bfren ecosystem](https://github.com/bfren/docker)

## Introduction

A [WireGuard](https://www.wireguard.com) VPN server. List the devices (peers) you want to connect, and the image creates their keys and configuration - shown as text or a QR code to scan with the WireGuard app. Peers send all their traffic through the server.

It is built on [Alpine + S6](https://github.com/bfren/docker-alpine-s6), with `wireguard-tools` from Alpine's packages, and uses the WireGuard support built into the host's Linux kernel.

## Quickstart

```yaml
services:
  wireguard:
    image: quay.io/bfren/wireguard:3.1
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    sysctls:
      - net.ipv4.ip_forward=1
    ports:
      - "0.0.0.0:51820:51820/udp"
    environment:
      - BF_WIREGUARD_EXTERNAL_ADDRESS=vpn.example.com
      - BF_WIREGUARD_PEERS=fred-phone fred-laptop jones-phone
    volumes:
      - ./v/config:/config
```

Run `docker compose up -d`, then show a peer's configuration:

```sh
docker compose exec wireguard wg-qr fred-phone      # scan with the WireGuard app
docker compose exec wireguard wg-conf fred-laptop   # copy into a .conf file
```

## Features

* 🔒 WireGuard VPN, sending all of each peer's traffic through the server
* 👥 Peers created from a list of names, with their own keys and a preshared key
* 📱 Peer configuration as text or a QR code
* 📊 Connected peers listed with names, addresses and traffic
* 💾 Keys kept in `/config`, so peers keep working when the container is replaced
* 🩺 Health check that WireGuard is listening
* 🧪 Built-in tests

## Tags

Images are published to Docker Hub (`bfren/wireguard`) and Quay.io (`quay.io/bfren/wireguard`) for `linux/amd64`, `linux/arm/v7` and `linux/arm64`, with `wireguard-tools` 1.0.20260223 on Alpine 3.24.

| Tag                          | Example                 | Use when                                    |
| ---------------------------- | ----------------------- | ------------------------------------------- |
| `latest`                     |                         | You always want the newest image            |
| `MAJOR`                      | `3`                     | You want updates, but not breaking changes  |
| `MINOR`                      | `3.1`                   | You want fixes only - **recommended**       |
| `VERSION`                    | `3.1.16`                | You want to pin this image exactly          |
| `wireguardX`, `wireguardX.Y` | `wireguard1.0`          | You want a `wireguard-tools` version        |
| `wireguardX.Y.Z`             | `wireguard1.0.20260223` | You want an exact `wireguard-tools` release |

## Configuration

### Ports

| Port        | Purpose   |
| ----------- | --------- |
| `51820/udp` | WireGuard |

Publish it as `51820:51820/udp` - peer configurations always connect to port 51820.

### Volumes

| Volume    | Purpose                                                                    |
| --------- | -------------------------------------------------------------------------- |
| `/config` | The server's keys, and a folder for each peer in `peers.d` - back this up. |

### Environment Variables

| Variable                         | Values        | Description                                                                         | Default    |
| -------------------------------- | ------------- | ----------------------------------------------------------------------------------- | ---------- |
| `BF_WIREGUARD_EXTERNAL_ADDRESS`  | host or IP    | **Required.** The address peers connect to.                                         |            |
| `BF_WIREGUARD_PEERS`             | names         | Peers to create, separated by spaces - see [Peers](#peers).                         |            |
| `BF_WIREGUARD_IP_RANGE`          | e.g. `10.8.0` | First three parts of the VPN's addresses - the server is `.1`. Use a private range. | `10.187.0` |
| `BF_WIREGUARD_IP_START_PEERS_AT` | number        | Last part of the first peer's address.                                              | `2`        |
| `BF_WIREGUARD_DNS`               | IP address    | DNS server peers use while connected.                                               | `1.1.1.1`  |
| `BF_WIREGUARD_INTERFACE`         | name          | Name of the WireGuard interface.                                                    | `wg0`      |

See [Alpine + S6](https://github.com/bfren/docker-alpine-s6#environment-variables) for `BF_DEBUG`, `BF_TZ` and the other base image variables.

### Host requirements

* A Linux kernel with WireGuard (5.6 or newer has it built in).
* `NET_ADMIN` capability, so the container can create the interface and firewall rules.
* `net.ipv4.ip_forward=1` for the container, so peers' traffic can be forwarded to the internet.

## How It Works

On every start:

1. The server's keys are created in `/config` if they don't exist.
2. Each peer in `BF_WIREGUARD_PEERS` gets a folder in `/config/peers.d` with its keys (created once) and its configuration (written every time, so changes to the range, DNS or address are picked up).
3. `/config/<interface>.conf` (e.g. `wg0.conf`) is written with every peer, and `wg-quick` brings the interface up, with firewall rules that forward and masquerade peers' traffic.

Peers are given addresses in order: the first gets `BF_WIREGUARD_IP_START_PEERS_AT`, the next one more, and so on. Their configuration sends all traffic, IPv4 and IPv6, through the VPN - the server only forwards IPv4, so IPv6 traffic is dropped rather than leaking outside the VPN.

The health check (every 30 seconds) checks WireGuard is listening on port 51820.

### Peers

Peer names must be unique, and are used as folder names. Because addresses are given in order:

* **add new peers to the end** of the list
* removing a peer, or changing the order, moves the peers after it to new addresses - show their configuration again and update their devices

### Helper commands

Run these with `docker exec <container> <command>` (add `-it` for `wg-show`).

| Command      | Arguments | Description                                                          |
| ------------ | --------- | -------------------------------------------------------------------- |
| `wg-conf`    | peer      | Show a peer's configuration.                                         |
| `wg-qr`      | peer      | Show a peer's configuration as a QR code.                            |
| `wg-clients` |           | List peers with their address, traffic and when they were last seen. |
| `wg-show`    |           | `wg show` with peer names, refreshing every 2 seconds.               |

## Testing

```sh
./test.sh                        # builds the image and runs /test
./run.sh 51820 vpn.example.com   # builds the image and opens a shell, with test peers and ./config mounted
```

`/test` runs this image's tests alongside the base images' tests: the peers list, peer addresses and files, reading `wg show` output for `wg-clients`, the generated interface and peer configuration, and the installed tools.

## Troubleshooting

### The container stops straight after starting

Usually the container is missing `NET_ADMIN`, or the host's kernel has no WireGuard - check `docker logs <container>`.

### Peers connect, but can't reach the internet

Check `net.ipv4.ip_forward=1` is set for the container (see [Host requirements](#host-requirements)), and that `BF_WIREGUARD_DNS` is reachable from the VPN.

### Peers can't connect at all

Check UDP port 51820 is published and allowed through any firewall or router, and that `BF_WIREGUARD_EXTERNAL_ADDRESS` reaches the server from outside your network.

### A peer stopped working after I changed the list

Its address changed - see [Peers](#peers). Show its configuration again with `wg-conf` or `wg-qr`.

## FAQs

### Why is the default range `10.187.0`?

It is a private range that is unlikely to clash with a home or office network, or with other VPNs. If it does, set `BF_WIREGUARD_IP_RANGE` to another private range, then show each peer's configuration again and update their devices.

### I'm upgrading from an image that used `187.0.0` - what do I need to do?

Older images used `187.0.0` by default, which is a public range. To keep your peers' existing configuration, set `BF_WIREGUARD_IP_RANGE=187.0.0`. To move to the new default, recreate the container, then show each peer's configuration again and update their devices.

### Can peers reach each other, or the server's network?

Yes - the firewall rules forward all traffic in and out of the VPN, so peers can reach each other, the internet, and other containers on the same Docker network. Reaching the host's LAN depends on your Docker networking.

## Licence

> [MIT](https://mit.bfren.dev/2023)

## Copyright

> Copyright (c) 2023-2026 [bfren](https://bfren.dev) (unless otherwise stated)
