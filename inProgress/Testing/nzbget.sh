#!/usr/bin/env bash

#https://hub.docker.com/r/linuxserver/nzbget

docker run -d --name nzbget \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=America/Chicago \
-p 6789:6789 \
-v /docker_exchange_host/config/nzbget:/config \
-v /docker_exchange_host/downloads:/downloads \
--restart unless-stopped \
linuxserver/nzbget
