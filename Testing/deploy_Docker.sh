#!/usr/bin/env bash

### Help Section ###
# Enter Dockers with "docker exec -it <container name> /bin/bash" some containers may only support ash


docker pull linuxserver/plex
docker pull linuxserver/sonarr
docker pull linuxserver/radarr
docker pull linuxserver/lidarr
docker pull linuxserver/mylar
docker pull linuxserver/jackett
docker pull linuxserver/nzbget
docker pull linuxserver/qbittorrent
docker pull mumiehub/rclone-mount

# Rclone-mount config
docker run -d --name rclone-mount \
    --restart=unless-stopped \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    --security-opt apparmor:unconfined \
    -e RemotePath="gdrive:Cloud" \
    -e MountCommands="--allow-other --allow-non-empty --min-age 2m --dir-cache-time=160h --cache-chunk-size=10M --cache-chunk-total-size=10G --cache-info-age=168h --cache-workers=6 --attr-timeout=1s --modify-window 1s --drive-use-trash=false --cache-writes --buffer-size=0M --daemon-timeout=10m --tpslimit 5" \
    -v /opt/tmp/config:/config \
    -v /DATA/media:/mnt/mediaefs:shared \
    mumiehub/rclone-mount


# Nzbget config
docker run -d --name nzbget \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -p 6790:6790 \
  -v /opt/tmp/config/nzbget:/config \
  -v /DATA/tmp/Downloads:/downloads \
  linuxserver/nzbget


# Jackett Config
docker run -d --name jackett \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -p 9117:9117 \
  -v /opt/tmp/config:/config \
  -v /DATA/tmp/Downloads/blackhole:/downloads \
  linuxserver/jackett


# Mylar Config
docker run -d --name mylar \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -p 8090:8090 \
  -v /opt/tmp/config:/config \
  -v /DATA/media/Comics:/comics \
  -v /DATA/tmp/Downloads/mylar/nzbget:/downloads \
  linuxserver/mylar



# Lidarr Config
docker run -d --name lidarr \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -p 8686:8686 \
  -v /opt/tmp/config/Lidarr:/config \
  -v /DATA/media/Music:/music \
  -v /DATA/tmp/Downloads/lidarr/nzbget:/downloads \
  linuxserver/lidarr



# Radarr Config
docker run -d --name radarr \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -p 7878:7878 \
  -v /opt/tmp/config/radarr:/config \
  -v /DATA/media/Movies:/movies \
  -v /DATA/tmp/Downloads/radarr/nzbget:/downloads \
  linuxserver/radarr



# Sonarr Config
docker run -d --name sonarr \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Chicago \
  -p 8989:8989 \
  -v /opt/tmp/config/sonarr:/config \
  -v /DATA/media/Tv_Shows:/tv \
  -v /DATA/tmp/Downloads/sonarr/nzbget:/downloads \
  --restart unless-stopped \
  linuxserver/sonarr


# Qbittorrent Config
  docker run -d --name qbittorrent \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Chicago \
    -e UMASK_SET=022 \
    -e WEBUI_PORT=8080 \
    -p 6881:6881 \
    -p 6881:6881/udp \
    -p 8080:8080 \
    -v /opt/tmp/config/qbittorrent:/config \
    -v /DATA/tmp/Downloads:/downloads \
    --restart unless-stopped \
    linuxserver/qbittorrent
