docker run --name vpn --cap-add=NET_ADMIN \
-e PUID=0 \
-e PGID=0 \
-e TZ=America/Chicago \
-e USER=XXX -e PASSWORD='XXX' \
-e REGION="CA Toronto" \
-e EXTRA_SUBNETS=192.168.20.0/24 \
-p 8080:8080/tcp \
 qmcgaw/private-internet-access
