#!/bin/sh

: "${NAME:=vim-ycm}"
: "${WORKDIR:=${HOME}}"
: "${PHOME=/config}"

VIM_YCM_CONFIG="${WORKDIR}/.vim-ycm"

if [ $# -gt 0 ]; then
    tag=$1
fi

docker rm --force ${NAME} 2>/dev/null

install -dm0700 ${VIM_YCM_CONFIG}
install -dm0700 ${VIM_YCM_CONFIG}/undo_history
install -dm0700 ${HOME}/.ssh
touch ${VIM_YCM_CONFIG}/bash_history
touch ${HOME}/.gitconfig

exec docker run -d                                                              \
                --restart unless-stopped                                        \
                --init                                                          \
                --env TERM=xterm-color                                          \
                --end XDG_CONFIG_HOME="${WORKDIR}"                              \
                --workdir "${WORKDIR}"                                          \
                --volume "${HOME}":"${WORKDIR}"                                 \
                --volume "${VIM_YCM_CONFIG}/bash_history":"${PHOME}/.bash_history" \
                --volume "${HOME}/.gitconfig":"${PHOME}/.gitconfig"             \
                --volume "${HOME}/.ssh":"${PHOME}/.ssh"                         \
                --volume "${VIM_YCM_CONFIG}/undo_history":"${PHOME}/.undo_history" \
                --hostname ${NAME}                                              \
                --name ${NAME}                                                  \
            ir1ka/vim-ycm${tag:+:${tag}} tail -f /dev/null
