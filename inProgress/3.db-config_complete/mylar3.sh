#!/usr/bin/env bash

#https://hub.docker.com/r/hotio/mylar3

# Mylar Config
docker create --name mylar \
  --network=host \
  -e ADVERTISE_IP="localhost:8090/" \
  -e PUID=1002 \
  -e PGID=1002 \
  -e TZ=America/Chicago \
  -v /opt/tmp/config:/config \
  -v /DATA/tmp/rclone-cache/Comics:/comics \
  -v /DATA/tmp/Downloads/mylar/nzbget:/downloads \
  hotio/mylar3
