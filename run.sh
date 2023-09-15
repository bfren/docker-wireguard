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
        -e WIREGUARD_PEERS="foo bar" \
        -p "0.0.0.0:${1}:51820" \
        -v $PWD/config:/etc/wireguard \
        wireguard-dev \
        sh
