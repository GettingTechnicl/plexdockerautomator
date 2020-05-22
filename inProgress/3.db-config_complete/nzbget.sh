#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/nzbget

# Nzbget config
docker run -d --name nzbget \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -p 6790:6790 \
  -v /opt/tmp/config/nzbget:/config \
  -v /DATA/tmp/Downloads:/downloads \
  linuxserver/nzbget
