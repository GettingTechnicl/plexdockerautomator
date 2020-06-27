#!/usr/bin/env bash

## This is the official Rclone docker containers
# https://hub.docker.com/r/rclone/rclone

docker pull rclone/rclone:latest

docker run --name rclone-cache \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--security-opt apparmor:unconfined \
-v /opt/tmp/config:/config \
-v /opt/tmp/cache:/cache \
-v /DATA/tmp/rclone-cache:/data:shared \
# -v /DATA/tmp/mergedhost:/mergedhost \
# need to add a script in this docker to move files from mergedhost to the rclone mount cache:
rclone/rclone mount cache: /data \
--cache-chunk-path /cache/rclone/cache-backend \
--cache-db-path /cache/rclone/cache-backend \
--config /config/rclone/rclone-cache.conf \
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
