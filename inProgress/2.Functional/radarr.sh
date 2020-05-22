#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/radarr

# Radarr Config
docker run -d --name radarr \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -p 7878:7878 \
  -v /opt/tmp/config/radarr:/config \
  -v /DATA/media/Movies:/movies \
  -v /DATA/tmp/Downloads/radarr/nzbget:/downloads \
  linuxserver/radarr
