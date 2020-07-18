

docker run --net=container:vpn \
  --name=qbittorrent \
  -e PUID=0 \
  -e PGID=0 \
  -e TZ=America/Chicago \
  -e WEBUI_PORT=8080 \
  -v /opt/tmp/config/qbittorrent:/config \
  -v /DATA/tmp/Downloads/torrent:/downloads \
  linuxserver/qbittorrent
