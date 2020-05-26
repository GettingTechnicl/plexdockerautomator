#!/usr/bin/env bash

## This is the official Rclone docker containers
# https://hub.docker.com/r/rclone/rclone

docker pull rclone/rclone:latest

docker run -d --name rclone-cache \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--security-opt apparmor:unconfined \
-v /docker_exchange_host/config:/config \
-v /docker_exchange_host/cache:/cache \
-v /docker_exchange_host/rclone-cache:/data:shared \
rclone/rclone mount cache: /data \
--cache-chunk-path /cache/rclone-cache/cache-backend \
--cache-db-path /cache/rclone-cache/cache-backend \
--cache-tmp-upload-path /cache/rclone-cache/tmp_upload \
--cache-dir /cache/rclone/cache \
--config /config/rclone/rclone.conf \
--allow-non-empty \
--allow-other \
--attr-timeout=1s \
--buffer-size=0M \
--cache-chunk-size=10M \
--cache-chunk-total-size=10G \
--cache-info-age=168h \
--cache-tmp-wait-time 15m \
--cache-workers=6 \
--daemon-timeout=10m \
--dir-cache-time=160h \
--drive-use-trash=false \
--fast-list \
--log-level INFO
