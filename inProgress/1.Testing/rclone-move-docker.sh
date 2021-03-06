#!/usr/bin/env bash


##https://hub.docker.com/r/pfidr/rclone


docker run --rm -it \
-v $(pwd)/config:/config \
-v /DATA/tmp/tmp_upload:/source \
-e RCLONE_CMD="move"
-e SYNC_SRC="/source" \
-e SYNC_DEST="gdrive:Cloud" \
-e TZ="America/Chicago" \
-e CRON="0 0 * * *" \
-e CRON_ABORT="0 6 * * *" \
-e FORCE_SYNC=1
-e CHECK_URL=https://hchk.io/hchk_uuid pfidr/rclone
