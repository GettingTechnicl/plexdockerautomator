#!/usr/bin/env bash

#https://hub.docker.com/r/hotio/mergerfs

# mergerfs Config
docker run -d --name mergerfs \
  --security-opt apparmor:unconfined \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --restart unless-stopped \
  -e PUID=0 \
  -e PGID=0 \
  -e TZ=America/Chicago \
  -v /DATA/tmp/test:/local \
  -v /DATA/tmp/rclone-cache:/gdrive \
  -v /DATA/tmp/mergedhost:/merged:shared \
  hotio/mergerfs -o defaults,direct_io,sync_read,allow_other,category.action=all,category.create=ff \
  /local:/gdrive \
  /merged
