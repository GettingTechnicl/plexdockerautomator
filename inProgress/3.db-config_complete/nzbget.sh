#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/nzbget

# Nzbget config
docker run -d --name nzbget \
  --restart unless-stopped \
  --network=host \
  -e ADVERTISE_IP="localhost:6790/" \
  -e PUID=1002 \
  -e PGID=1002 \
  -e TZ=America/Chicago \
  -v /opt/tmp/config/nzbget:/config \
  -v /DATA/tmp/Downloads:/downloads \
  linuxserver/nzbget
