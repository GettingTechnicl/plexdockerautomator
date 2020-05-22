#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/lidarr

docker run --name=lidarr \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -e UMASK_SET=022 `#optional` \
  -p 8686:8686 \
  -v /docker_exchange_host/config/lidarr:/config \
  -v /docker_exchange_host/gdrive/Music:/music \
  -v /docker_exchange_host/downloads:/downloads \
  --restart unless-stopped \
  linuxserver/lidarr
