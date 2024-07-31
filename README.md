# Docker WireGuard

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-wireguard) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fwireguard) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fwireguard) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-wireguard/dev.yml?branch=main)

[Docker Repository](https://hub.docker.com/r/bfren/wireguard) - [bfren ecosystem](https://github.com/bfren/docker)

Comes with [WireGuard](https://www.wireguard.com/) pre-installed.

Once started you can show configuration for a peer in two ways:

```bash
# print configuration as text
wg-conf peer1

# print configuration as QR code
wg-qr peer1

# print all registered clients with connection statistics
wg-clients

# show all clients, auto refreshing every 2sec (similar to wg show)
wg-show
```

## Contents

* [Ports](#ports)
* [Volumes](#volumes)
* [Environment Variables](#environment-variables)
* [Helper Functions](#helper-functions)
* [Licence / Copyright](#licence)

## Ports

* 51820

## Volumes

| Volume    | Purpose                                       |
| --------- | --------------------------------------------- |
| `/config` | Stores server and peer configuration values.  |

## Environment Variables

| Variable                          | Values | Description                                                                              | Default               |
| --------------------------------- | ------ | ---------------------------------------------------------------------------------------- | --------------------- |
| `BF_WIREGUARD_EXTERNAL_ADDRESS`   | string | The external IP Address or domain of the server - peers will use this to connect.        | *None* - **required** |
| `BF_WIREGUARD_INTERFACE`          | string | The name to use for the WireGuard interface.                                             | wg0                   |
| `BF_WIREGUARD_IP_RANGE`           | string | The IP range to use for the WireGuard host and peers - **without** the final segment.    | 192.168.100           |
| `BF_WIREGUARD_DNS`                | string | The IP Address of an upstream DNS resolver.                                              | 1.1.1.1 (Cloudflare)  |
| `BF_WIREGUARD_PEERS`              | string | List of peers to create on startup.                                                      | *Blank*               |

## Helper Functions

| Function      | Arguments     | Description                                       |
| ------------- | ------------- | ------------------------------------------------- |
| `wg-clients`  | *none*        | Displays all configured clients with statistics.  |
| `wg-conf`     | 0: Peer name  | Display a peer's configuration as text.           |
| `wg-show`     | *none*        | Displays output from `wg show` with client names. |
| `wg-qr`       | 0: Peer name  | Display a peer's configuration as a QR code.      |

## Licence

> [MIT](https://mit.bfren.dev/2023)

## Copyright

> Copyright (c) 2023-2024 [bfren](https://bfren.dev) (unless otherwise stated)
