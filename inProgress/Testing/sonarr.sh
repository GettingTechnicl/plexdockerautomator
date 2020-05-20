#!/usr/bin/env bash

## New Sonarr version


##need variable to connect to nzbget, right now only connects ip, but what about other systems?
docker run -d --name sonarr-sma \
    --restart=unless-stopped \
    --cap-add SYS_ADMIN \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Chicago \
    -p 8989:8989 \
    -v /docker_exchange_host/config/sonarr:/config \
    -v /docker_exchange_host/config/sma:/usr/local/sma/config \
    -v /docker_exchange_host/gdrive/Tv_Shows:/tv \
    -v /docker_exchange_host/Downloads/sonarr:/downloads \
    mdhiggins/sonarr-sma:preview
