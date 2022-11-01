#!/usr/bin/env bash

GIT_BRANCH=${1:-$(git branch --show-current)}
NAME="warp-$GIT_BRANCH"
echo "Starting docker compose project with name: $NAME"
docker-compose --project-name=$NAME up -d
