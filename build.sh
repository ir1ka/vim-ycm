#!/bin/bash

CURR_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ $# -eq 0 ]; then
    tag=$1
fi

exec docker build -t ir1ka/vim-ycm${tag:+:${tag}} \
                  --build-arg TAG=12 \
                  --build-arg PUSER=$USER \
                  --build-arg PUID=$UID \
                  --pull \
            ${CURR_DIR}
