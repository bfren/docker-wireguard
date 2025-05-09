FROM ghcr.io/bfren/alpine-s6:alpine3.21-5.5.4

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-wireguard"

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

EXPOSE 51820/udp

COPY ./overlay /

ENV \
    # the IP address or name of the DNS resolver
    BF_WIREGUARD_DNS=1.1.1.1 \
    # the IP address or name of the host server
    BF_WIREGUARD_EXTERNAL_ADDRESS= \
    # the name of the WireGuard interface
    BF_WIREGUARD_INTERFACE=wg0 \
    # the IP range of the WireGuard interface (do NOT include the final number)
    BF_WIREGUARD_IP_RANGE=187.0.0 \
    # the final number of the IP address to start at (will be added to BF_WIREGUARD_IP_RANGE)
    BF_WIREGUARD_IP_START_PEERS_AT=2 \
    # space-separated list of WireGuard peers - these will be created automatically
    BF_WIREGUARD_PEERS=

RUN bf-install

VOLUME [ "/config" ]
