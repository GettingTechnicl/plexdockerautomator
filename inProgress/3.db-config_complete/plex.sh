docker run -d --name plex \
--network=host \
-e TZ="America/Chicago" \
-e PLEX_CLAIM="<claimToken>" \
-e ADVERTISE_IP="http://192.168.20.5:32400/" \
-v /opt/tmp/config/plexdb:/config \
-v /mnt/ramdisk:/transcode \
-v /DATA/rclone-cache:/data \
plexinc/pms-docker
