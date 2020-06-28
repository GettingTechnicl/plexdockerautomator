#!/usr/bin/env bash

### Help Section ###
# Enter Dockers with "docker exec -it <container name> /bin/bash" some containers may only support ash

#####################################################
# Print working directory - Do Not edit
target_PWD="$(readlink -f .)"
#####################################################


# TimeZone
tZone="America/Chicago"

# Your Plex claim Token
cToken="<claimToken>"

# Your ADVERTISE_IP setting here
adv_Ip=localhost

# root directory specified for all databases (recommended on SSD) (no trailing forwardslash)
rdbDir=/opt/tmp

# root directory specified for heavy IO
rioDir=/DATA/tmp

# root directory for cache
rcloneCacheDir=/DATA/tmp

# Your preferred PUID (run "id youruser" to find your uid/guid)
prefPUID=1002

# Your Preferred GUID
prefGUID=1002

# Rclone preferred PUID (rclone must be run as root)
RcprefPUID=0

# Rclone Preferred GUID
RcprefGUID=0

# Docker Command
dCMD="create"

# Directories Required
sudo mkdir -p /mnt/ramdisk
sudo mkdir -p ${rdbDir}
sudo mkdir -p ${rcloneCacheDir}/cache/rclone
sudo mkdir -p ${rdbDir}/config
sudo mkdir -p ${rdbDir}/config/plexdb
sudo mkdir -p ${rdbDir}/config/Lidarr
sudo mkdir -p ${rdbDir}/config/nzbget
sudo mkdir -p ${rdbDir}/config/ombi
sudo mkdir -p ${rdbDir}/config/radarr
sudo mkdir -p ${rdbDir}/config/sma
sudo mkdir -p ${rdbDir}/config/rclone
sudo mkdir -p ${rioDir}
sudo mkdir -p ${rioDir}/rclone-vfs
sudo mkdir -p ${rioDir}/rclone-cache
sudo mkdir -p ${rioDir}/Downloads
sudo mkdir -p ${rioDir}/Downloads/blackhole
sudo mkdir -p ${rioDir}/Downloads/lidarr/nzbget
sudo mkdir -p ${rioDir}/Downloads/mylar/nzbget
sudo mkdir -p ${rioDir}/Downloads/radarr/nzbget
sudo mkdir -p ${rioDir}/Downloads/sonarr/nzbget

sudo chmod -R 777 ${rioDir}
sudo chown -R root.root ${rdbDir}
chmod g+s -R ${rioDir}
chmod g+s -R ${rdbDir}

sudo usermod -aG sudo plex


# Rclone Cache config
docker ${dCMD} --name rclone-cache \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--security-opt apparmor:unconfined \
-e PUID=${RcprefPUID} \
-e GUID=${RcprefGUID} \
-v ${rdbDir}/config:/config \
-v ${rcloneCacheDir}/cache:/cache \
-v ${rioDir}/rclone-cache:/data:shared \
rclone/rclone mount cache: /data \
--cache-chunk-path /cache/rclone/cache-backend \
--cache-db-path /cache/rclone/cache-backend \
--config /config/rclone/cache_config/rclone.conf \
--allow-non-empty \
--allow-other \
--attr-timeout=1s \
--buffer-size=0M \
--cache-chunk-size=64M \
--cache-chunk-total-size=1000G \
--cache-info-age=168h \
--cache-workers=6 \
--daemon-timeout=10m \
--dir-cache-time=160h \
--drive-use-trash=false \
--drive-chunk-size 64M \
--fast-list \
--log-file /config/rclone/rclone-cache.log \
--rc \
--rc-addr :5573 \
--log-level INFO


# Rclone VFS Config
docker ${dCMD} --name rclone-vfs \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--security-opt apparmor:unconfined \
-e PUID=${RcprefPUID} \
-e GUID=${RcprefGUID} \
-v ${rcloneCacheDir}/cache:/cache \
-v ${rdbDir}/config:/config \
-v ${rioDir}/rclone-vfs:/data:shared \
rclone/rclone mount gdrive:Cloud /data \
--cache-dir /cache/rclone-vfs \
--config /config/rclone/vfs_config/rclone.conf \
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
--vfs-read-chunk-size-limit off \
--rc \
--rc-addr :5572 \
--log-file /config/rclone/rclone-vfs.log \
--log-level INFO


docker ${dCMD} --name rclone-sync \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--security-opt apparmor:unconfined \
-e PUID=${RcprefPUID} \
-e GUID=${RcprefGUID} \
-v ${rdbDir}/config/rclone/cache_config:/root/.config/rclone \
-v ${rioDir}/tmp_upload:/source \
-e SYNC_SRC="/source" \
-e SYNC_DEST="cache:test" \
-e TZ=America/Chicago \
-e CRON="*/2 * * * *" \
-e CRON_ABORT="0 6 * * *" \
-e FORCE_SYNC=1 \
-e CHECK_URL=https://hchk.io/hchk_uuid \
-e RCLONE_OPTS="--log-file /root/.config/rclone/rclone-sync.log --log-level INFO" \
-e SYNC_OPTS="-v --delete-after" \
bcardiff/rclone


# merge local layer and cloud drive
docker ${dCMD} --name mergerfs \
  --security-opt apparmor:unconfined \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --restart unless-stopped \
  -e PUID=0 \
  -e PGID=0 \
  -e TZ=${tZone} \
  -v ${rioDir}/tmp_upload:/local \
  -v ${rioDir}/rclone-cache:/cloud_drive \
  -v ${rioDir}/mergerfs:/merged:shared \
  hotio/mergerfs -o defaults,direct_io,sync_read,allow_other,category.action=all,category.create=ff \
  /local:/cloud_drive \
  /merged



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
  -v ${rdbDir}/config/jackett:/config \
  -v ${rioDir}/Downloads/blackhole:/downloads \
  linuxserver/jackett


# Lidarr Config
  docker ${dCMD} --name lidarr \
    --network=host \
    -e ADVERTISE_IP="${adv_Ip}:8686/" \
    -e PUID=${prefPUID} \
    -e PGID=${prefGUID} \
    -e TZ=${tZone} \
    -v ${rdbDir}/config/lidarr:/config \
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
        docker ${dCMD} --name ombi \
          --network=host \
          -e ADVERTISE_IP="${adv_Ip}:3579/" \
          -e PUID=${prefPUID} \
          -e PGID=${prefGUID} \
          -e TZ=${tZone} \
          -v ${rdbDir}/config/ombi:/config \
          linuxserver/ombi



          # Radarr Config
          docker ${dCMD} --name radarr \
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
           docker ${dCMD} --name sonarr \
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



            # Copies SystemD service scripts to systemD
            sudo mv ${target_PWD}/Systemd/* /etc/systemd/system/
            sudo systemctl enable rclone-cache.service
            sudo systemctl enable rclone-vfs.service
            sudo systemctl enable rclone-sync.service
            sudo systemctl enable mergerfs.service
            sudo systemctl enable jackett.service
            sudo systemctl enable lidarr.service
            sudo systemctl enable mylar.service
            sudo systemctl enable nzbget.service
            sudo systemctl enable plex.service
            sudo systemctl enable radarr.service
            sudo systemctl enable sonarr.service
            sudo systemctl enable ombi.service

            sudo systemctl start rclone-cache.service
            sudo systemctl start rclone-vfs.service
            sudo systemctl start rclone-sync.service
            sleep 2
            sudo systemctl start mergerfs.service
            sleep 2
            sudo systemctl start jackett.service
            sudo systemctl start lidarr.service
            sudo systemctl start mylar.service
            sudo systemctl start nzbget.service
            sudo systemctl start plex.service
            sudo systemctl start radarr.service
            sudo systemctl start sonarr.service
            sudo systemctl start ombi.service
