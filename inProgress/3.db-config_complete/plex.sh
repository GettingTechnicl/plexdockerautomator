docker run -d --name plex \
--network=host \
-e PUID=1002 \
-e PGID=1002 \
-e TZ="America/Chicago" \
-e PLEX_CLAIM="<claimToken>" \
-e ADVERTISE_IP="http://localhost:32400/" \
-v /opt/tmp/config/plexdb:/config \
-v /mnt/ramdisk:/transcode \
-v /DATA/tmp/rclone-vfs:/data \
plexinc/pms-docker
