#!/bin/bash
set -e

: "${PUSER:=${USER}}"
: "${PUID:=${UID}}"
: "${WORKDIR:=/work}"
: "${TAG:=12}"

CURR_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ $# -gt 0 ]; then
    tag=$1
fi

exec docker build -t ir1ka/vim-ycm${tag:+:${tag}} \
                  --build-arg TAG=${TAG} \
                  --build-arg PUSER=${PUSER} \
                  --build-arg PUID=${PUID} \
                  --build-arg WORKDIR=${WORKDIR} \
                  --pull \
            ${CURR_DIR}
