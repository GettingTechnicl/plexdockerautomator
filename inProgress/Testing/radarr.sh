docker run -d --name radarr \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -e UMASK_SET=022 `#optional` \
  -p 7878:7878 \
  -v /docker_exchange_host/config:/config \
  -v /docker_exchange_host/gdrive/Movies:/movies \
  -v /docker_exchange_host/Downloads:/downloads \
  --restart unless-stopped \
  linuxserver/radarr
