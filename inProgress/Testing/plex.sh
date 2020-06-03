docker run -d --name plex \
-e TZ="America/Chicago" \
-e PLEX_CLAIM="<claimToken>" \
-e ADVERTISE_IP="http://192.168.20.5:32400/" \
-p 32400:32400/tcp \
-p 3005:3005/tcp \
-p 8324:8324/tcp \
-p 32469:32469/tcp \
-p 1900:1900/udp \
-p 32410:32410/udp \
-p 32412:32412/udp \
-p 32413:32413/udp \
-p 32414:32414/udp \
-v /opt/tmp/config/plexdb:/config \
-v /mnt/ramdisk:/transcode \
-v /DATA/media:/data \
plexinc/pms-docker