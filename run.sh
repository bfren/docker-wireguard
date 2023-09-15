#!/bin/sh

IMAGE=`cat VERSION`

docker buildx build \
    --load \
    --build-arg BF_IMAGE=wireguard \
    --build-arg BF_VERSION=${IMAGE} \
    -f Dockerfile \
    -t wireguard-dev \
    . \
    && \
    docker run -it \
        --cap-add=NET_ADMIN \
        -e BF_DEBUG=1 \
        -e WIREGUARD_EXTERNAL_ADDRESS=${2:-changeme} \
        -e WIREGUARD_PEERS="foo bar" \
        -p "0.0.0.0:${1:-51820}:51820/udp" \
        -v $PWD/config:/etc/wireguard \
        wireguard-dev \
        sh
