#!/usr/bin/env bash

## This is the official Rclone docker containers
# https://hub.docker.com/r/rclone/rclone

docker pull rclone/rclone:latest

docker run -d --name rclone \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--security-opt apparmor:unconfined \
-v /opt/tmp/config:/config \
-v /DATA/media:/data:shared \
rclone/rclone mount gdrive:Cloud /DATA/gdrive \
--config /config/rclone/rclone.conf \
--allow-other \
--allow-non-empty \
--fast-list \
--buffer-size 256M \
--drive-chunk-size 32M \
--dir-cache-time 96h \
--log-level DEBUG \
--timeout 1h \
--tpslimit 4 \
--umask 002 \
--rc \
--vfs-cache-mode writes \
--vfs-read-chunk-size 128M \
--vfs-read-chunk-size-limit off \
--cache-dir /DATA/cache \
