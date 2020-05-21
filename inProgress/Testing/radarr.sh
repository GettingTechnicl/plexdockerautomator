#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/radarr

docker run -d --name radarr \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -e UMASK_SET=022 `#optional` \
  -p 7878:7878 \
  -v /docker_exchange_host/config/radarr:/config \
  -v /docker_exchange_host/gdrive/Movies:/movies \
  -v /docker_exchange_host/downloads:/downloads \
  --restart unless-stopped \
  linuxserver/radarr
