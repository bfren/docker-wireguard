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
        --network="host" \
        -e BF_DEBUG=1 \
        -e WIREGUARD_EXTERNAL_ADDRESS=changeme \
        -e WIREGUARD_PEERS="foo bar" \
        -v $PWD/config:/etc/wireguard \
        wireguard-dev \
        sh
