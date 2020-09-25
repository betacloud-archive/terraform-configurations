#!/usr/bin/env bash

sed -i -e "s/HOSTNAME/$(hostname)/g" /home/ubuntu/service/configuration/okeanos.xyz.db

docker-compose --no-ansi -f /home/ubuntu/service/docker-compose.yml pull -q

sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

sudo rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf

docker-compose --no-ansi -f /home/ubuntu/service/docker-compose.yml up -d
docker-compose --no-ansi -f /home/ubuntu/service/docker-compose.yml restart coredns
