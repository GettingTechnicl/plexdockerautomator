#!/usr/bin/env bash

### Help Section ###
# Enter Dockers with "docker exec -it <container name> /bin/bash" some containers may only support ash


# Print working directory - Do Not edit
target_PWD="$(readlink -f .)"
# TimeZone
tZone="America/Chicago"
# Your Plex claim Token
cToken="<claimToken>"
# Your ADVERTISE_IP setting here
adv_Ip=http://localhost
# root directory specified for all databases (recommended on SSD) (no trailing forwardslash)
rdbDir=/opt/PDA
# root directory specified for heavy IO
rioDir=/DATA/PDA



# Plex Config
docker run -d --name plex \
--network=host \
-e TZ=${tZone} \
-e PLEX_CLAIM=${cToken} \
-e ADVERTISE_IP=${adv_Ip}:32400 \
-v ${rdbDir}/config/plexdb:/config \
-v /mnt/ramdisk:/transcode \
-v ${rioDir}/rclone-vfs:/data \
plexinc/pms-docker


# Jackett Config
docker run -d --name jackett \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=${tZone} \
  -p 9117:9117 \
  -v ${rdbDir}/config:/config \
  -v ${rioDir}/tmp/Downloads/blackhole:/downloads \
  linuxserver/jackett


# Lidarr Config
  docker run -d --name lidarr \
    --restart unless-stopped \
    --network=host \
    -e ADVERTISE_IP="localhost:8686/" \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=${tZone} \
    -v ${rdbDir}/config/Lidarr:/config \
    -v /DATA/tmp/rclone-cache/Music:/music \
    -v /DATA/tmp/Downloads/lidarr/nzbget:/downloads \
    linuxserver/lidarr


    # Mylar Config
    docker run -d --name mylar \
      --restart unless-stopped \
      --network=host \
      -e ADVERTISE_IP="localhost:8090/" \
      -e PUID=1000 \
      -e PGID=1000 \
      -e TZ=${tZone} \
      -v ${rdbDir}/config:/config \
      -v /DATA/tmp/rclone-cache/Comics:/comics \
      -v /DATA/tmp/Downloads/mylar/nzbget:/downloads \
      hotio/mylar3



      # Nzbget config
      docker run -d --name nzbget \
        --restart unless-stopped \
        --network=host \
        -e ADVERTISE_IP="localhost:6790/" \
        -e PUID=1000 \
        -e PGID=1000 \
        -e TZ=${tZone} \
        -v ${rdbDir}/config/nzbget:/config \
        -v /DATA/tmp/Downloads:/downloads \
        linuxserver/nzbget



        #Ombi config
        docker run -d --name=ombi \
          --network=host \
          -e ADVERTISE_IP="localhost:3579/" \
          -e PUID=1000 \
          -e PGID=1000 \
          -e TZ=${tZone} \
          -v ${rdbDir}/config/ombi:/config \
          --restart unless-stopped \
          linuxserver/ombi



          # Radarr Config
          docker run -d --name radarr-sma \
            --restart unless-stopped \
            --network=host \
            -e ADVERTISE_IP="localhost:7878/" \
            -e PUID=1000 \
            -e PGID=1000 \
            -e TZ=${tZone} \
            -v ${rdbDir}/config/radarr:/config \
            -v /DATA/tmp/rclone-cache/Movies:/movies \
            -v /DATA/tmp/rclone-cache/Stand_Ups:/standups \
            -v /DATA/tmp/Downloads/radarr/nzbget:/downloads \
            mdhiggins/radarr-sma



           # Sonarr config

           docker run -d --name sonarr-sma \
           --restart=unless-stopped \
           --cap-add SYS_ADMIN \
           --network=host \
           -e ADVERTISE_IP="localhost:6790/" \
           -e PUID=1000 \
           -e PGID=1000 \
           -e TZ=${tZone} \
           -v ${rdbDir}/config/sma:/usr/local/sma/config \
           -v ${rdbDir}/config/sonarr:/config \
           -v /DATA/tmp/rclone-cache/Tv_Shows:/tv \
           -v /DATA/tmp/Downloads/sonarr/nzbget:/downloads \
           mdhiggins/sonarr-sma:preview



            # Rclone Cache config
            docker pull rclone/rclone:latest

            docker run --name rclone-cache \
            --restart=unless-stopped \
            --cap-add SYS_ADMIN \
            --device /dev/fuse \
            --security-opt apparmor:unconfined \
            -v ${rdbDir}/config:/config \
            -v ${rdbDir}/cache:/cache \
            -v /DATA/tmp/rclone-cache:/data:shared \
            rclone/rclone mount cache:Cloud /data \
            --cache-chunk-path /cache/rclone-cache/cache-backend \
            --cache-db-path /cache/rclone-cache/cache-backend \
            --cache-tmp-upload-path /cache/rclone-cache/tmp_upload \
            --cache-dir /cache/rclone/cache \
            --config /config/rclone/rclone-cache.conf \
            --allow-non-empty \
            --allow-other \
            --attr-timeout=1s \
            --buffer-size=0M \
            --cache-chunk-size=10M \
            --cache-chunk-total-size=100G \
            --cache-info-age=168h \
            --cache-tmp-wait-time 15m \
            --cache-workers=6 \
            --daemon-timeout=10m \
            --dir-cache-time=160h \
            --drive-use-trash=false \
            --fast-list \
            --log-level INFO



            # Rclone VFS Config

            docker run -d --name rclone-vfs \
            --restart=unless-stopped \
            --cap-add SYS_ADMIN \
            --device /dev/fuse \
            --security-opt apparmor:unconfined \
            -v ${rdbDir}/cache:/cache \
            -v ${rdbDir}/config:/config \
            -v /DATA/tmp/rclone-vfs:/data:shared \
            rclone/rclone mount gdrive:Cloud /data \
            --cache-dir /cache/rclone-vfs \
            --config /config/rclone/rclone-vfs.conf \
            --allow-other \
            --allow-non-empty \
            --buffer-size 256M \
            --dir-cache-time 96h \
            --drive-chunk-size 32M \
            --fast-list \
            --log-level DEBUG \
            --rc \
            --timeout 1h \
            --tpslimit 4 \
            --umask 002 \
            --vfs-cache-mode writes \
            --vfs-read-chunk-size 128M \
            --vfs-read-chunk-size-limit off
