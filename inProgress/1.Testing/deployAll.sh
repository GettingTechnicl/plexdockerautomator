${PDAuser}#!/usr/bin/env bash

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
rdbDir=/DATA/pda/docker-exchange

# root directory specified for heavy IO
rioDir=/DATA/pda/iops

#LogDir
logdir=/var/log/pda

# rclone cloud name
rcN='gdrive:Cloud'

# root directory for cache
rcloneBufferSize=100M
rcloneCacheDir=${rioDir}/rclonecache
rcloneCacheSize=1000G
rcloneVfsCacheSize=100G

# Your preferred PUID (run "id youruser" to find your uid/guid)
prefPUID=1002

# Your Preferred GUID
prefGUID=1002

# Rclone preferred PUID (rclone must be run as root)
RcprefPUID=1002

# Rclone Preferred GUID
RcprefGUID=1002

# Docker Command
dCMD=create

# Owner of all data / should be same user as PUID
PDAuser=plex

# Docker Network Name
dNET=pda

## Website Config INFO
# WebURL
wURL=base1.heyzzeus.com
# Unencrypted Port
hPORT=80
# Encrypted Port
hPORTS=443
# Only Subdomains (true/false)
oSD=true

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
sudo mkdir -p ${rdbDir}/config/nginx
sudo mkdir -p ${rioDir}
sudo mkdir -p ${rioDir}/rclone-vfs
sudo mkdir -p ${rioDir}/rclone-cache
sudo mkdir -p ${rioDir}/rclonecache/cache
sudo mkdir -p ${rioDir}/rclonecache/vfscache
sudo mkdir -p ${rioDir}/Downloads
sudo mkdir -p ${rioDir}/Downloads/blackhole
sudo mkdir -p ${rioDir}/Downloads/lidarr/nzbget
sudo mkdir -p ${rioDir}/Downloads/mylar/nzbget
sudo mkdir -p ${rioDir}/Downloads/radarr/nzbget
sudo mkdir -p ${rioDir}/Downloads/sonarr/nzbget
sudo mkdir -p ${logdir}
sudo mkdir -p ${rioDir}/mergerfs/tmp_upload
sudo mkdir -p ${rioDir}/mergerfs/gdrive
sudo mkdir -p ${rioDir}/mergerfs/fusepoint

sudo addgroup pda
sudo usermod -aG pda ${PDAuser}
sudo chown -R root.pda ${rioDir}
sudo chown -R root.pda ${rdbDir}
sudo chown -R root.pda ${logdir}
sudo chmod -R 2751 ${rioDir}
sudo chmod -R 2751 ${rdbDir}
sudo chmod -R 2751 ${logdir}

# Create Plexdocker network
docker network create ${dNET}

# Remove rclone-cache if it exists
docker stop rclone-cache
docker rm rclone-cache
# Rclone Cache config
docker ${dCMD} --name rclone-cache \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e PUID=${RcprefPUID} \
  -e GUID=${RcprefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/rclone-cache:/config/rclone \
  -v ${rcloneCacheDir}/rclonecache/cache:/cache \
  -v ${rioDir}/rclonecache/cache:/data:shared \
  -v ${logdir}:/logs \
  rclone/rclone mount cache: /data \
  --cache-chunk-path /cache/rclone/cache-backend \
  --cache-db-path /cache/rclone/cache-backend \
  --config /config/rclone/rclone.conf \
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
  --log-file /logs/rclone-cache.log \
  --rc \
  --rc-addr :5573 \
  --log-level INFO

# Remove Rclone-vfs if it exists
docker stop rclone-vfs
docker rm rclone-vfs
# Rclone VFS Config
docker ${dCMD} --name rclone-vfs \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e PUID=${RcprefPUID} \
  -e GUID=${RcprefGUID} \
  -e TZ=${tZone} \
  -v ${rcloneCacheDir}/vfscache:/cache \
  -v ${rdbDir}/config/rclone-vfs:/config/rclone \
  -v ${rioDir}/rclone-vfs:/data:shared \
  -v ${logdir}:/logs \
  rclone/rclone mount ${rcN} /data \
  --cache-dir /cache/rclone-vfs \
  --config /config/rclone/rclone.conf \
  --allow-other \
  --allow-non-empty \
  --buffer-size ${rcloneBufferSize} \
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
  --log-file /logs/rclone-vfs.log \
  --log-level INFO




# Remove rclone-move if it exists
docker stop rclone-move
docker rm rclone-move
# https://github.com/robinostlund/docker-rclone-sync
#rcloneopts should have log level but errors about -v,
docker ${dCMD} --name rclone-move \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e PUID=${RcprefPUID} \
  -e GUID=${RcprefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/rclone/cache_config:/root/.config/rclone \
  -v ${rioDir}/mergerfs/tmp_upload:/source \
  -e RCLONE_CMD="move" \
  -e SYNC_SRC="/source" \
  -e SYNC_DEST="${rcN}" \
  -e CRON="*/15 * * * *" \
  -e CRON_ABORT="0 6 * * *" \
  -e RCLONE_OPTS="--transfers=5 --min-age 2h --exclude *.{mkv,avi,original} --log-file /root/.config/rclone/rclone-move.log" \
  -e FORCE_SYNC=1 \
  pfidr/rclone


# Remove mergerfs if it exists
docker stop mergerfs
docker rm mergerfs
# merge local layer and cloud drive
docker ${dCMD} --name mergerfs \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e PUID=${RcprefPUID} \
  -e GUID=${RcprefGUID} \
  -e TZ=${tZone} \
  -v ${rioDir}/mergerfs/tmp_upload:/local \
  -v ${rioDir}/mergerfs/gdrive:/cloud_drive \
  -v ${rioDir}/mergerfs/fusepoint:/merged:shared \
  hotio/mergerfs -o defaults,direct_io,sync_read,allow_other,nonempty,category.action=all,category.create=ff \
  /local:/cloud_drive \
  /merged


# Remove plex if it exists
docker stop plex
docker rm plex
# Plex Config
docker ${dCMD} --name plex \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    --security-opt apparmor:unconfined \
    --network=${dNET} \
    -e TZ=${tZone} \
    -e PLEX_CLAIM=${cToken} \
    -e ADVERTISE_IP="${adv_Ip}:32400/" \
    -e PUID=${prefPUID} \
    -e PGID=${prefGUID} \
    -v ${rdbDir}/config/plexdb:/config \
    -v /mnt/ramdisk:/transcode \
    -v ${rioDir}/rclone-vfs:/data \
    horjulf/plex_autoscan

# Remove jackett if it exists
docker stop jackett
docker rm jackett
# Jackett Config
docker ${dCMD} --name jackett \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e ADVERTISE_IP="${adv_Ip}:9117/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/jackett:/config \
  -v ${rioDir}/Downloads/blackhole:/downloads \
  linuxserver/jackett

# Remove lidarr if it exists
docker stop lidarr
docker rm lidarr
# Lidarr Config
docker ${dCMD} --name lidarr \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e ADVERTISE_IP="${adv_Ip}:8686/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/lidarr:/config \
  -v ${rioDir}/fusepoint/Music:/music \
  -v ${rioDir}/Downloads/lidarr/nzbget:/downloads \
  linuxserver/lidarr

# Remove mylar if it exists
docker stop mylar
docker rm mylar
# Mylar Config
docker ${dCMD} --name mylar \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e ADVERTISE_IP="${adv_Ip}:8090/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/mylar:/config \
  -v ${rioDir}/fusepoint/Comics:/comics \
  -v ${rioDir}/Downloads/mylar/nzbget:/downloads \
  hotio/mylar3


# Remove nzbget if it exists
docker stop nzbget
docker rm nzbget
# Nzbget config
docker ${dCMD} --name nzbget \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e ADVERTISE_IP="${adv_Ip}:6789/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/nzbget:/config \
  -v ${rioDir}/Downloads:/downloads \
  linuxserver/nzbget


  # Remove qbittorrent if it exists
  docker stop qbittorrent
  docker rm qbittorrent
  # Qbittorrent Config
  docker ${dCMD} --name qbittorrent \
    --network=${dNET}:vpn \
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

# Remove ombi if it exists
docker stop ombi
docker rm ombi
#Ombi config
docker ${dCMD} --name ombi \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e ADVERTISE_IP="${adv_Ip}:3579/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/ombi:/config \
  linuxserver/ombi


# Remove radarr if it exists
docker stop radarr
docker rm radarr
# Radarr Config
docker ${dCMD} --name radarr \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e ADVERTISE_IP="${adv_Ip}:7878/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/radarr:/config \
  -v ${rdbDir}/config/sma:/usr/local/sma/config \
  -v ${rioDir}/fusepoint/Movies:/movies \
  -v ${rioDir}/fusepoint/Stand_Ups:/standups \
  -v ${rioDir}/Downloads:/downloads \
  mdhiggins/radarr-sma:preview


# Remove sonarr if it exists
docker stop sonarr
docker rm sonarr
# Sonarr config
docker ${dCMD} --name sonarr \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  --network=${dNET} \
  -e ADVERTISE_IP="${adv_Ip}:6790/" \
  -e PUID=${prefPUID} \
  -e PGID=${prefGUID} \
  -e TZ=${tZone} \
  -v ${rdbDir}/config/sonarr:/config \
  -v ${rdbDir}/config/sma:/usr/local/sma/config \
  -v ${rioDir}/fusepoint/Tv_Shows:/tv \
  -v ${rioDir}/fusepoint/Anime:/anime \
  -v ${rioDir}/Downloads:/downloads \
  mdhiggins/sonarr-sma:preview


# Remove nginx if it exists
docker stop nginx
docker rm nginx
# Nginx Docker Config
docker ${dCMD} --name=nginx \
--cap-add=NET_ADMIN \
--network=${dNET} \
-e PUID=${prefPUID} \
-e PGID=${prefGUID} \
-e TZ=${tZone} \
-e URL=${wURL} \
-e SUBDOMAINS=www, \
-e VALIDATION=http \
-e DNSPLUGIN=cloudflare \
-e ONLY_SUBDOMAINS=${oSD} \
-p ${hPORTS}:443 \
-p ${hPORT}:80 \
-v ${rdbDir}/config/nginx:/config \
    ghcr.io/linuxserver/swag

# Stops previous system services if there are any
sudo systemctl stop rclone-cache.service
sudo systemctl stop rclone-vfs.service
sudo systemctl stop rclone-move.service
sudo systemctl stop mergerfs.service
sudo systemctl stop jackett.service
sudo systemctl stop lidarr.service
sudo systemctl stop mylar.service
sudo systemctl stop nzbget.service
sudo systemctl stop plex.service
sudo systemctl stop radarr.service
sudo systemctl stop sonarr.service
sudo systemctl stop ombi.service
sudo systemctl stop qbittorrent.service
sudo systemctl stop nginx.service

# Removes previous SystemD Scripts if they exist
sudo rm -rf /etc/systemd/system/rclone-cache.service
sudo rm -rf /etc/systemd/system/rclone-vfs.service
sudo rm -rf /etc/systemd/system/rclone-move.service
sudo rm -rf /etc/systemd/system/mergerfs.service
sudo rm -rf /etc/systemd/system/jackett.service
sudo rm -rf /etc/systemd/system/lidarr.service
sudo rm -rf /etc/systemd/system/mylar.service
sudo rm -rf /etc/systemd/system/nzbget.service
sudo rm -rf /etc/systemd/system/plex.service
sudo rm -rf /etc/systemd/system/radarr.service
sudo rm -rf /etc/systemd/system/sonarr.service
sudo rm -rf /etc/systemd/system/ombi.service
sudo rm -rf /etc/systemd/system/qbittorrent.service
sudo rm -rf /etc/systemd/system/nginx.service

# Copies SystemD service scripts to systemD
sudo cp -a ${target_PWD}/Systemd/. ${target_PWD}/workspace.local
sudo sed -i "s|CACHEPATH|${rioDir}|g" ${target_PWD}/workspace.local/rclone-cache.service
sudo sed -i "s|VFSPATH|${rioDir}|g" ${target_PWD}/workspace.local/rclone-vfs.service
sudo sed -i "s|MERGERPATH|${rioDir}|g" ${target_PWD}/workspace.local/mergerfs.service
sudo mv ${target_PWD}/workspace.local/* /etc/systemd/system/

sudo systemctl daemon-reload
#sudo systemctl enable rclone-cache.service
#sudo systemctl enable rclone-vfs.service
#sudo systemctl enable rclone-move.service
#sudo systemctl enable mergerfs.service
#sudo systemctl enable jackett.service
#sudo systemctl enable lidarr.service
#sudo systemctl enable mylar.service
#sudo systemctl enable nzbget.service
#sudo systemctl enable plex.service
#sudo systemctl enable radarr.service
#sudo systemctl enable sonarr.service
#sudo systemctl enable ombi.service
#sudo systemctl enable qbittorrent.service
#sudo systemctl enable nginx.service
#sudo systemctl start rclone-cache.service
#sudo systemctl start rclone-vfs.service
#sudo systemctl start rclone-move.service
#sudo systemctl start mergerfs.service
#sudo systemctl start jackett.service
#sudo systemctl start lidarr.service
#sudo systemctl start mylar.service
#sudo systemctl start nzbget.service
#sudo systemctl start plex.service
#sudo systemctl start radarr.service
#sudo systemctl start sonarr.service
#sudo systemctl start ombi.service
#sudo systemctl start qbittorrent.service
#sudo systemctl start nginx.service
