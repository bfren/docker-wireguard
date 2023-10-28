#!/bin/sh

IMAGE=`cat VERSION`

CONFIG=$PWD/config
rm -rf ${CONFIG}

docker buildx build \
    --load \
    --progress plain \
    --build-arg BF_IMAGE=wireguard \
    --build-arg BF_VERSION=${IMAGE} \
    -f Dockerfile \
    -t wireguard-dev \
    . \
    && \
    docker run -it \
        --cap-add=NET_ADMIN \
        -e BF_DEBUG=1 \
        -e BF_WIREGUARD_EXTERNAL_ADDRESS=${2:-changeme} \
        -e BF_WIREGUARD_PEERS="foo-personal   bar-work fred    jones" \
        -p "0.0.0.0:${1:-51820}:51820/udp" \
        -v ${CONFIG}:/config \
        wireguard-dev \
        sh
