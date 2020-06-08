#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/ombi

docker run -d --name=ombi \
  --network=host \
  -e ADVERTISE_IP="localhost:3579/" \
  -e PUID=1002 \
  -e PGID=1002 \
  -e TZ=America/Chicago \
  -v /opt/tmp/config/ombi:/config \
  --restart unless-stopped \
  linuxserver/ombi
