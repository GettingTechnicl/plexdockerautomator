#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/jackett

docker run -d --name=jackett \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Chicago \
    -p 9117:9117 \
    -v /docker_exchange_host/config/jackett:/config \
    -v /docker_exchange_host/downloads:/downloads \
    --restart unless-stopped \
    linuxserver/jackett
