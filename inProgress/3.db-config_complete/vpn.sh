docker run --name vpn \
--cap-add=NET_ADMIN \
--device=/dev/net/tun
-e PUID=0 \
-e PGID=0 \
-e TZ=America/Chicago \
-e USER=XXX \
-e PASSWORD='XXX' \
-e REGION="CA Toronto" \
-e EXTRA_SUBNETS=172.17.0.1/16 \
-p 8080:8080/tcp \
 qmcgaw/private-internet-access
