#!/usr/bin/env bash

### Help Section ###
# Enter Dockers with "docker exec -it <container name> /bin/bash" some containers may only support ash

#####################################################
# Print working directory - Do Not edit
target_PWD="$(readlink -f .)"
#####################################################


# TimeZone
tZone=America/Chicago

# Your Plex claim Token
cToken="<claimToken>"

# Your ADVERTISE_IP setting here
adv_Ip=http://localhost

# root directory specified for all databases (recommended on SSD) (no trailing forwardslash)
rdbDir=/opt/tmp

# root directory specified for heavy IO
rioDir=/DATA/tmp

# root directory for cache
rcloneCacheDir=/DATA/tmp
rcloneCacheSize=1000G
rcloneVfsCacheSize=100G

# Your preferred PUID (run "id youruser" to find your uid/guid)
prefPUID=1002

# Your Preferred GUID
prefGUID=1002

# Rclone preferred PUID (rclone must be run as root)
RcprefPUID=0

# Rclone Preferred GUID
RcprefGUID=1002

# Docker Command
dCMD=create

# Directories Required
sudo mkdir -p /mnt/ramdisk
sudo mkdir -p ${rdbDir}
sudo mkdir -p ${rcloneCacheDir}/cache/rclone
sudo mkdir -p ${rdbDir}/config
sudo mkdir -p ${rdbDir}/config/plexdb
sudo mkdir -p ${rdbDir}/config/lidarr
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
sudo chown -R plex.plex ${rdbDir}
chmod g+s -R ${rioDir}
chmod g+s -R ${rdbDir}

sudo usermod -aG sudo plex


# Rclone Cache config
docker ${dCMD} --name rclone-cache \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e PUID=${RcprefPUID} \
  -e GUID=${RcprefGUID} \
  -e TZ=${tZone} \
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
  --cache-chunk-total-size=${rcloneCacheSize} \
  --cache-info-age=168h \
  --cache-workers=6 \
  --daemon-timeout=10m \
  --dir-cache-time=160h \
  --drive-use-trash=false \
  --drive-chunk-size=64M \
  --fast-list \
  --log-file /config/rclone/rclone-cache.log \
  --rc \
  --rc-addr :5573 \
  --log-level INFO


# Rclone VFS Config
docker ${dCMD} --name rclone-vfs \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e PUID=${RcprefPUID} \
  -e GUID=${RcprefGUID} \
  -e TZ=${tZone} \
  -v ${rcloneCacheDir}/cache:/cache \
  -v ${rdbDir}/config:/config \
  -v ${rioDir}/rclone-vfs:/data:shared \
  rclone/rclone mount gdrive:Cloud /data \
  --cache-dir /cache/rclone-vfs \
  --config /config/rclone/vfs_config/rclone.conf \
  --allow-other \
  --allow-non-empty \
  --buffer-size ${rcloneVfsCacheSize} \
  --cache-dir /cache/rclone-vfs \
  --fast-list \
  --log-level INFO \
  --rc \
  --timeout 1h \
  --tpslimit 4 \
  --umask 002 \
  --vfs-cache-mode writes \
  --vfs-cache-max-size ${rcloneVfsCacheSize} \
  --vfs-read-chunk-size-limit 500M \
  --vfs-read-chunk-size 100M \
  --rc \
  --rc-addr :5572 \
  --log-file /config/rclone/rclone-vfs.log \
  --log-level INFO





# https://github.com/robinostlund/docker-rclone-sync

#rcloneopts should have log level but errors about -v,
docker ${dCMD} --name rclone-move \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e PUID=${RcprefPUID} \
  -e GUID=${RcprefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/rclone/cache_config:/root/.config/rclone \
  -v ${rioDir}/tmp_upload:/source \
  -e RCLONE_CMD="move" \
  -e SYNC_SRC="/source" \
  -e SYNC_DEST="gdrive:Cloud" \
  -e CRON="*/5 * * * *" \
  -e CRON_ABORT="0 6 * * *" \
  -e RCLONE_OPTS="--transfers=5 --min-age 2h --exclude *.{mkv,avi,original} --log-file /root/.config/rclone/rclone-move.log" \
  -e FORCE_SYNC=1 \
  pfidr/rclone



# merge local layer and cloud drive
docker ${dCMD} --name mergerfs \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e PUID=${RcprefPUID} \
  -e GUID=${RcprefGUID} \
  -e TZ=${tZone} \
  -v ${rioDir}/tmp_upload:/local \
  -v ${rioDir}/rclone-cache:/cloud_drive \
  -v ${rioDir}/mergerfs:/merged:shared \
  hotio/mergerfs -o defaults,direct_io,sync_read,allow_other,nonempty,category.action=all,category.create=ff \
  /local:/cloud_drive \
  /merged



# Plex Config
  docker ${dCMD} --name plex \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    --security-opt apparmor:unconfined \
    --network=host \
    -e TZ=${tZone} \
    -e PLEX_CLAIM=${cToken} \
    -e ADVERTISE_IP="${adv_Ip}:32400/" \
    -e PUID=${prefPUID} \
    -e PGID=${prefGUID} \
    -v ${rdbDir}/config/plexdb:/config \
    -v /mnt/ramdisk:/transcode \
    -v ${rioDir}/rclone-vfs:/data \
    horjulf/plex_autoscan


# Jackett Config
docker ${dCMD} --name jackett \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e ADVERTISE_IP="${adv_Ip}:9117/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/jackett:/config \
  -v ${rioDir}/Downloads/blackhole:/downloads \
  linuxserver/jackett


# Lidarr Config
docker ${dCMD} --name lidarr \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e ADVERTISE_IP="${adv_Ip}:8686/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/lidarr:/config \
  -v ${rioDir}/mergerfs/Music:/music \
  -v ${rioDir}/Downloads/lidarr/nzbget:/downloads \
  linuxserver/lidarr


# Mylar Config
docker ${dCMD} --name mylar \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e ADVERTISE_IP="${adv_Ip}:8090/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/mylar:/config \
  -v ${rioDir}/mergerfs/Comics:/comics \
  -v ${rioDir}/Downloads/mylar/nzbget:/downloads \
  hotio/mylar3



# Nzbget config
docker ${dCMD} --name nzbget \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e ADVERTISE_IP="${adv_Ip}:6789/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/nzbget:/config \
  -v ${rioDir}/Downloads:/downloads \
  linuxserver/nzbget


  docker ${dCMD} --name qbittorrent \
    --network=container:vpn \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    --security-opt apparmor:unconfined \
    -e PUID=${prefPUID} \
    -e PGID=${prefGUID} \
    -e TZ=${tZone} \
    -e WEBUI_PORT=9090 \
    -v ${rdbDir}/config/qbittorrent:/config \
    -v ${rioDir}/Downloads:/downloads \
    linuxserver/qbittorrent


#Ombi config
docker ${dCMD} --name ombi \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e ADVERTISE_IP="${adv_Ip}:3579/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/ombi:/config \
  linuxserver/ombi



# Radarr Config
docker ${dCMD} --name radarr \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e ADVERTISE_IP="${adv_Ip}:7878/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/radarr:/config \
  -v ${rdbDir}/config/sma:/usr/local/sma/config \
  -v ${rioDir}/mergerfs/Movies:/movies \
  -v ${rioDir}/mergerfs/Stand_Ups:/standups \
  -v ${rioDir}/Downloads:/downloads \
  mdhiggins/radarr-sma:preview



# Sonarr config
docker ${dCMD} --name sonarr \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=host \
  -e ADVERTISE_IP="${adv_Ip}:6790/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/sonarr:/config \
  -v ${rdbDir}/config/sma:/usr/local/sma/config \
  -v ${rioDir}/mergerfs/Tv_Shows:/tv \
  -v ${rioDir}/Downloads:/downloads \
  mdhiggins/sonarr-sma:preview



# Copies SystemD service scripts to systemD
sudo cp -a ${target_PWD}/Systemd/. ${target_PWD}/workspace.local
sudo sed -i "s|CACHEPATH|${rioDir}|g" ${target_PWD}/workspace.local/rclone-cache.service
sudo sed -i "s|VFSPATH|${rioDir}|g" ${target_PWD}/workspace.local/rclone-vfs.service
sudo sed -i "s|MERGERPATH|${rioDir}|g" ${target_PWD}/workspace.local/mergerfs.service
sudo mv ${target_PWD}/workspace.local/* /etc/systemd/system/

sudo systemctl enable rclone-cache.service
sudo systemctl enable rclone-vfs.service
sudo systemctl enable rclone-move.service
sudo systemctl enable mergerfs.service
sudo systemctl enable jackett.service
sudo systemctl enable lidarr.service
sudo systemctl enable mylar.service
sudo systemctl enable nzbget.service
sudo systemctl enable plex.service
sudo systemctl enable radarr.service
sudo systemctl enable sonarr.service
sudo systemctl enable ombi.service
sudo systemctl enable qbittorrent.service
sudo systemctl start rclone-cache.service
sudo systemctl start rclone-vfs.service
sudo systemctl start rclone-move.service
sudo systemctl start mergerfs.service
sudo systemctl start jackett.service
sudo systemctl start lidarr.service
sudo systemctl start mylar.service
sudo systemctl start nzbget.service
sudo systemctl start plex.service
sudo systemctl start radarr.service
sudo systemctl start sonarr.service
sudo systemctl start ombi.service
sudo systemctl start qbittorrent.service
