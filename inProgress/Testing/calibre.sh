#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/calibre-web

#setting db path not working
  docker run -d --name=calibre \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Chicago \
    -e DOCKER_MODS=/docker_exchange_host/config/calibre/mods:calibre \
    -p 8083:8083 \
    -v /docker_exchange_host/config/calibre:/config \
    -v /docker_exchange_host/gdrive/Books:/books \
    --restart unless-stopped \
    linuxserver/calibre-web
