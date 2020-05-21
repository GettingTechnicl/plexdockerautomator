#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/ombi

docker run -d --name=ombi \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -p 3579:3579 \
  -v /docker_exchange_host/config/ombi:/config \
  --restart unless-stopped \
  linuxserver/ombi
