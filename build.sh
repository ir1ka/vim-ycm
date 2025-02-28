#!/bin/bash
set -e

: "${PUSER:=}"
: "${PUID:=}"
: "${WORKDIR:=}"
: "${TAG:=}"

CURR_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ $# -gt 0 ]; then
    tag=$1
fi

exec docker build -t ir1ka/vim-ycm${tag:+:${tag}} \
                  ${TAG:+--build-arg TAG=${TAG}} \
                  ${PUSER:+--build-arg PUSER=${PUSER}} \
                  ${PUID:+--build-arg PUID=${PUID}} \
                  ${WORKDIR:+--build-arg WORKDIR=${WORKDIR}} \
                  --pull \
            ${CURR_DIR}
