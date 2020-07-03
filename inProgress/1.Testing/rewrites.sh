#!/usr/bin/env bash

target_PWD="$(readlink -f .)"



# Copies SystemD service scripts to systemD
sudo cp -a ${target_PWD}/Systemd/. ${target_PWD}/workspace.local
sudo sed -i "s|CACHEPATH|${rioDir}|g" ${target_PWD}/workspace.local/rclone-cache.service
sudo sed -i "s|VFSPATH|${rioDir}|g" ${target_PWD}/workspace.local/rclone-vfs.service
sudo sed -i "s|MERGERPATH|${rioDir}|g" ${target_PWD}/workspace.local/mergerfs.service
#sudo mv ${target_PWD}/workspace.local/* /etc/systemd/system/
