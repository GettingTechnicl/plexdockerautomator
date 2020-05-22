#https://hub.docker.com/r/horjulf/plex_autoscan
docker run --name=plex \
-e VERSION=latest \
-e PUID=1000 \
-e PGID=1000 \
-p 32400:32400 \
-e TZ=America/Chicago \
-v /docker_exchange_host/config:/config \
-v /docker_exchange_host/gdrive/Tv_Shows:/data/tvshows \
-v /docker_exchange_host/gdrive/Movies:/data/movies \
-v /docker_exchange_host/plex_transcode:/transcode \
horjulf/plex_autoscan
