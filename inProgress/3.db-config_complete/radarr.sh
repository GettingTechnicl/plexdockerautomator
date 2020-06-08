#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/radarr

# Radarr Config
docker run -d --name radarr-v3 \
  --restart unless-stopped \
  --network=host \
  -e ADVERTISE_IP="localhost:7878/" \
  -e PUID=1002 \
  -e PGID=1002 \
  -e TZ=America/Chicago \
  -v /opt/tmp/config/radarr:/config \
  -v /DATA/tmp/rclone-cache/Movies:/movies \
  -v /DATA/tmp/rclone-cache/Stand_Ups:/standups \
  -v /DATA/tmp/Downloads/radarr/nzbget:/downloads \
  mdhiggins/radarr-sma:preview
