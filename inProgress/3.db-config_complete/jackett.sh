#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/jackett

# Jackett Config
docker run -d --name jackett \
  --restart unless-stopped \
  -e PUID=1002 \
  -e PGID=1002 \
  -e TZ=America/Chicago \
  -p 9117:9117 \
  -v /opt/tmp/config:/config \
  -v /DATA/tmp/Downloads/blackhole:/downloads \
  linuxserver/jackett
