#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/lidarr

# Lidarr Config
docker run -d --name lidarr \
  --restart unless-stopped \
  --network=host \
  -e ADVERTISE_IP="localhost:8686/" \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -v /opt/tmp/config/Lidarr:/config \
  -v /DATA/tmp/rclone-cache/Music:/music \
  -v /DATA/tmp/Downloads/lidarr/nzbget:/downloads \
  linuxserver/lidarr
