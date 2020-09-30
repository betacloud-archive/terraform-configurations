#!/usr/bin/env bash

docker-compose --no-ansi -f /home/ubuntu/service/docker-compose.yml pull -q
docker-compose --no-ansi -f /home/ubuntu/service/docker-compose.yml up -d
