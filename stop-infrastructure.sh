#!/usr/bin/env bash

GIT_BRANCH=${1:-$(git branch --show-current)}
NAME="warp-$GIT_BRANCH"
echo "Stopping docker compose project with name: $NAME"
docker-compose --project-name=$NAME stop
