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
rclone/rclone mount gdrive:Cloud /data/gdrive --config /config/rclone/rclone.conf --allow-other --allow-non-empty --min-age 2m --dir-cache-time=160h --cache-chunk-size=10M --cache-chunk-total-size=10G --cache-info-age=168h --cache-workers=6 --attr-timeout=1s --modify-window 1s --drive-use-trash=false --cache-writes --buffer-size=0M --daemon-timeout=10m --tpslimit 5"
