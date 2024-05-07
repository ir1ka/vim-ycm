#!/bin/sh

: "${NAME:=vim-ycm}"
: "${WORKDIR:=/work}"
: "${PUSER:=${USER}}"
: "${PHOME=/home/${PUSER}}"

if [ $# -gt 0 ]; then
    tag=$1
fi

docker rm --force ${NAME} 2>/dev/null

touch ${HOME}/.bash_history
exec docker run -d                                                              \
                --restart unless-stopped                                        \
                --init                                                          \
                --env TERM=xterm-color                                          \
                --volume "${HOME}":"${WORKDIR}":rw                              \
                --volume "${HOME}/.bash_history":"${PHOME}/.bash_history:rw"    \
                --hostname ${NAME}                                              \
                --name ${NAME}                                                  \
            ir1ka/vim-ycm${tag:+:${tag}} tail -f /dev/null
