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

docker stop jackett
docker stop lidarr
docker stop mylar
docker stop nzbget
docker stop ombi
docker stop plex
docker stop radarr
docker stop rclone-cache
docker stop rclone-vfs
docker stop sonarr

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

chmod +x /home/root/plexdockerautomator/inProgress/deploy_Docker.sh
