#!/usr/bin/env bash

#https://hub.docker.com/r/hotio/mylar3

docker run --name mylar3 \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=America/Chicago \
-p 8090:8090 \
-v /docker_exchange_host/config/mylar3:/config \
-v /docker_exchange_host/downloads:/downloads \
-v /docker_exchange_host/gdrive/Comics:/comics \
--restart unless-stopped \
hotio/mylar3