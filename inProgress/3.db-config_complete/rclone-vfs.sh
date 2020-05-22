#!/usr/bin/env bash

## This is the official Rclone docker containers
# https://hub.docker.com/r/rclone/rclone

docker pull rclone/rclone:latest

docker run -d --name rclone-vfs \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--security-opt apparmor:unconfined \
-v /opt/tmp/cache:/cache \
-v /opt/tmp/config:/config \
-v /DATA/rclone-vfs:/data:shared \
rclone/rclone mount gdrive:Cloud /data \
--cache-dir /cache/rclone-vfs \
--config /config/rclone/rclone.conf \
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
