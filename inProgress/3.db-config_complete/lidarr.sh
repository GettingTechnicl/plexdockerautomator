#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/lidarr

# Lidarr Config
docker run -d --name lidarr \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -p 8686:8686 \
  -v /opt/tmp/config/Lidarr:/config \
  -v /DATA/media/Music:/music \
  -v /DATA/tmp/Downloads/lidarr/nzbget:/downloads \
  linuxserver/lidarr
