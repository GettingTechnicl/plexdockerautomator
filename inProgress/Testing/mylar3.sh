#!/usr/bin/env bash

#https://hub.docker.com/r/hotio/mylar3

# Mylar Config
docker run -d --name mylar \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -p 8090:8090 \
  -v /opt/tmp/config:/config \
  -v /DATA/media/Comics:/comics \
  -v /DATA/tmp/Downloads/mylar/nzbget:/downloads \
  hotio/mylar3
