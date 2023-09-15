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
        --cap-add=SYS_MODULE \
        -p "0.0.0.0:${1}:51820" \
        wireguard-dev \
        sh
