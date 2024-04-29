#!/bin/sh

: "${NAME:=vim-ycm}"

docker rm --force ${NAME} 2>/dev/null
exec docker run -d                          \
                --restart unless-stopped    \
                --init                      \
                --env TERM=xterm-color      \
                --volume "${HOME}":/work:rw \
                --hostname ${NAME}          \
                --name ${NAME}              \
            ir1ka/vim-ycm:latest tail -f /dev/null
