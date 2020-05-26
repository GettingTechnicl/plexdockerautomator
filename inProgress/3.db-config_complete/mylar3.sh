#!/usr/bin/env bash

#https://hub.docker.com/r/hotio/mylar3

# Mylar Config
docker run -d --name mylar \
  --restart unless-stopped \
  --network=host \
  -e ADVERTISE_IP="localhost:8090/" \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -v /opt/tmp/config:/config \
  -v /DATA/rclone-cache/Comics:/comics \
  -v /DATA/tmp/Downloads/mylar/nzbget:/downloads \
  hotio/mylar3
