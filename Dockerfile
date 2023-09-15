FROM bfren/alpine-s6:alpine3.18-4.5.7

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-wireguard"

ARG BF_IMAGE
ARG BF_VERSION

EXPOSE 51820/udp

ENV \
    # the IP address or name of the host server
    WIREGUARD_EXTERNAL_ADDRESS= \
    # the name of the WireGuard interface
    WIREGUARD_INTERFACE=wg0 \
    # the IP range of the WireGuard interface (do NOT include the final number)
    WIREGUARD_IP_RANGE=192.168.100 \
    # the IP address or name of the DNS resolver
    WIREGUARD_PEER_DNS=1.1.1.1 \
    # space-separated list of WireGuard peers
    WIREGUARD_PEERS=

COPY ./overlay /

RUN bf-install

VOLUME [ "/config" ]
