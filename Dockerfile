FROM bfren/alpine-s6:alpine3.18-4.5.7

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-wireguard"

ARG BF_IMAGE
ARG BF_VERSION

EXPOSE 51820/udp

ENV \
    # the name of the WireGuard interface
    WIREGUARD_INTERFACE=wg0 \
    # the IP address of the WireGuard interface
    WIREGUARD_IP_ADDRESS=192.168.100.1

COPY ./overlay /

RUN bf-install

VOLUME [ "/etc/wireguard" ]
