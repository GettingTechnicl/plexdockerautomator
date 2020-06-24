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
# Your preferred PUID
prefPUID=1000
# Your Preferred GUID
prefGUID=1000
# Docker Command
dCMD="create"


mkdir ${rioDir}
mkdir ${rdbDir}

# Plex Config
docker ${dCMD} --name plex \
--network=host \
-e TZ=${tZone} \
-e PLEX_CLAIM=${cToken} \
-e ADVERTISE_IP="${adv_Ip}:32400" \
-v ${rdbDir}/config/plexdb:/config \
-v /mnt/ramdisk:/transcode \
-v ${rioDir}/rclone-vfs:/data \
plexinc/pms-docker


# Jackett Config
docker ${dCMD} --name jackett \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -p 9117:9117 \
  -v ${rdbDir}/config:/config \
  -v ${rioDir}/Downloads/blackhole:/downloads \
  linuxserver/jackett


# Lidarr Config
  docker ${dCMD} --name lidarr \
    --network=host \
    -e ADVERTISE_IP="${adv_Ip}:8686/" \
    -e PUID=${prefPUID} \
    -e PGID=${prefGUID} \
    -e TZ=${tZone} \
    -v ${rdbDir}/config/Lidarr:/config \
    -v ${rioDir}/rclone-cache/Music:/music \
    -v ${rioDir}/Downloads/lidarr/nzbget:/downloads \
    linuxserver/lidarr


    # Mylar Config
    docker ${dCMD} --name mylar \
      --network=host \
      -e ADVERTISE_IP="${adv_Ip}:8090/" \
      -e PUID=${prefPUID} \
      -e PGID=${prefGUID} \
      -e TZ=${tZone} \
      -v ${rdbDir}/config:/config \
      -v ${rioDir}/rclone-cache/Comics:/comics \
      -v ${rioDir}/Downloads/mylar/nzbget:/downloads \
      hotio/mylar3



      # Nzbget config
      docker ${dCMD} --name nzbget \
        --network=host \
        -e ADVERTISE_IP="${adv_Ip}:6790/" \
        -e PUID=${prefPUID} \
        -e PGID=${prefGUID} \
        -e TZ=${tZone} \
        -v ${rdbDir}/config/nzbget:/config \
        -v ${rioDir}/Downloads:/downloads \
        linuxserver/nzbget



        #Ombi config
        docker ${dCMD} --name=ombi \
          --network=host \
          -e ADVERTISE_IP="${adv_Ip}:3579/" \
          -e PUID=${prefPUID} \
          -e PGID=${prefGUID} \
          -e TZ=${tZone} \
          -v ${rdbDir}/config/ombi:/config \
          linuxserver/ombi



          # Radarr Config
          docker ${dCMD} --name radarr-sma \
            --network=host \
            -e ADVERTISE_IP="${adv_Ip}:7878/" \
            -e PUID=${prefPUID} \
            -e PGID=${prefGUID} \
            -e TZ=${tZone} \
            -v ${rdbDir}/config/radarr:/config \
            -v ${rioDir}/rclone-cache/Movies:/movies \
            -v ${rioDir}/rclone-cache/Stand_Ups:/standups \
            -v ${rioDir}/Downloads/radarr/nzbget:/downloads \
            mdhiggins/radarr-sma:preview



           # Sonarr config
           docker ${dCMD} --name sonarr-sma \
           --cap-add SYS_ADMIN \
           --network=host \
           -e ADVERTISE_IP="${adv_Ip}:6790/" \
           -e PUID=${prefPUID} \
           -e PGID=${prefGUID} \
           -e TZ=${tZone} \
           -v ${rdbDir}/config/sma:/usr/local/sma/config \
           -v ${rdbDir}/config/sonarr:/config \
           -v ${rioDir}/rclone-cache/Tv_Shows:/tv \
           -v ${rioDir}/Downloads/sonarr/nzbget:/downloads \
           mdhiggins/sonarr-sma:preview



            # Rclone Cache config
            docker ${dCMD} --name rclone-cache \
            --restart=unless-stopped \
            --cap-add SYS_ADMIN \
            --device /dev/fuse \
            --security-opt apparmor:unconfined \
            -v ${rdbDir}/config:/config \
            -v ${rdbDir}/cache:/cache \
            -v ${rioDir}/rclone-cache:/data:shared \
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
            docker ${dCMD} --name rclone-vfs \
            --restart=unless-stopped \
            --cap-add SYS_ADMIN \
            --device /dev/fuse \
            --security-opt apparmor:unconfined \
            -v ${rdbDir}/cache:/cache \
            -v ${rdbDir}/config:/config \
            -v ${rioDir}/rclone-vfs:/data:shared \
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
