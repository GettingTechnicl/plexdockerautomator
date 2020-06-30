#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/radarr

# Radarr Config
docker run --name radarr \
  --network=host \
  -e ADVERTISE_IP="localhost:7878/" \
  -e PUID=0 \
  -e PGID=0 \
  -v /opt/tmp/config/radarr:/config \
  -v /opt/tmp/config/sma:/usr/local/sma/config \
  -v /DATA/tmp/rclone-cache/Movies:/movies \
  -v /DATA/tmp/rclone-cache/Stand_Ups:/standups \
  -v /DATA/tmp/Downloads/radarr/nzbget:/downloads/radarr/nzbget \
  mdhiggins/radarr-sma:preview
