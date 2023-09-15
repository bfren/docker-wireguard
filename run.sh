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
        -e BF_DEBUG=1 \
        -e WIREGUARD_EXTERNAL_ADDRESS=changeme \
        -e WIREGUARD_PEERS="foo bar" \
        -p "0.0.0.0:${1}:51820/udp" \
        -v $PWD/config:/etc/wireguard \
        -v /lib/modules:/lib/modules \
        --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
        wireguard-dev \
        sh
