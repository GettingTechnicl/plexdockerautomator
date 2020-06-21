#!/usr/bin/env bash

## This is the official Rclone docker containers
# https://hub.docker.com/r/rclone/rclone

docker pull rclone/rclone:latest

docker run -d --name rclone-cache \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--security-opt apparmor:unconfined \
-v /opt/tmp/config:/config \
-v /opt/tmp/cache:/cache \
-v /DATA/tmp/rclone-cache:/data:shared \
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
--cache-chunk-size=128M \
--cache-chunk-total-size=200G \
--cache-info-age=168h \
--cache-tmp-wait-time 15m \
--cache-workers=6 \
--daemon-timeout=10m \
--dir-cache-time=160h \
--drive-use-trash=false \
--drive-chunk-size 128M \
--fast-list \
--log-level INFO






docker run -d --name rclone-cache \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--security-opt apparmor:unconfined \
-v /opt/tmp/config:/config \
-v /opt/tmp/cache:/cache \
-v /DATA/tmp/rclone-cache:/data:shared \
rclone/rclone mount cache: /data \
--cache-chunk-path /cache/rclone-cache/cache-backend \
--cache-db-path /cache/rclone-cache/cache-backend \
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







docker run --name rclone-cache \
--restart=unless-stopped \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--security-opt apparmor:unconfined \
-e PUID=1002 \
-e PGID=1002 \
-v /docker_exchange_host/config:/config \
-v /docker_exchange_host/cache:/cache \
-v /docker_exchange_host/rclone-cache:/data:shared \
rclone/rclone mount cache: /data \
--cache-chunk-path /cache/rclone-cache/cache-backend \
--cache-db-path /cache/rclone-cache/cache-backend \
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




--userns=plex
