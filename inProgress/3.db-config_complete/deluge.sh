docker run --net=container:vpn --name=deluge \
  -e ADVERTISE_IP="localhost:8112/" \
  -e PUID=0 \
  -e PGID=0 \
  -e TZ=America/Chicago \
  -e DELUGE_LOGLEVEL=error \
  -v /opt/tmp/config/deluge:/config \
  -v /DATA/tmp/Downloads/torrent:/downloads \
  linuxserver/deluge
