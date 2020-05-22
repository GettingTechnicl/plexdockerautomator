docker run -d --name plex \
--network=host \
-e TZ="America/Chicago" \
-e PLEX_CLAIM="<claimToken>" \
-v /opt/tmp/config/plexdb:/config \
-v /mnt/ramdisk:/transcode \
-v /DATA/media:/data \
plexinc/pms-docker
