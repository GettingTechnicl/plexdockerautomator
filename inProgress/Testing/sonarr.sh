#!/usr/bin/env bash

#https://hub.docker.com/r/mdhiggins/sonarr-sma

## New Sonarr version

##need variable to connect to nzbget, right now only connects ip, but what about other systems
docker run -d --name sonarr-sma \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=America/Chicago \
-p 8989:8989 \
-v /opt/tmp/config/sma:/usr/local/sma/config \
-v /opt/tmp/config/sonarr:/config \
-v /DATA/media/Tv_Shows:/tv \
-v /DATA/tmp/Downloads/sonarr/nzbget:/downloads \
mdhiggins/sonarr-sma:preview
