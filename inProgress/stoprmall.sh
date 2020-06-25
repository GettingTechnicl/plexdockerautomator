#!/usr/bin/env bash

service jackett stop
service lidarr stop
service mylar stop
service nzbget stop
service ombi stop
service plex stop
service radarr stop
service rclone-cache stop
service rclone-vfs stop
service sonarr stop

docker rm jackett
docker rm lidarr
docker rm mylar
docker rm nzbget
docker rm ombi
docker rm plex
docker rm radarr
docker rm rclone-cache
docker rm rclone-vfs
docker rm sonarr

docker system prune -a

git reset --hard
git pull

chmod +x stoprmall.sh
chmod +x deploy_Docker.sh
