#!/bin/sh

: "${NAME:=vim-ycm}"
: "${WORKDIR:=${HOME}}"
: "${PHOME=/config}"

if [ $# -gt 0 ]; then
    tag=$1
fi

docker rm --force ${NAME} 2>/dev/null

touch ${HOME}/.${NAME}.bash_history
touch ${HOME}/.${NAME}.viminfo
touch ${HOME}/.gitconfig

install -dm0700 ${HOME}/.ssh
install -dm0700 ${HOME}/.${NAME}.undo_history

exec docker run -d                                                              \
                --restart unless-stopped                                        \
                --init                                                          \
                --env TERM=xterm-color                                          \
                --workdir "${WORKDIR}"                                          \
                --volume "${HOME}":"${WORKDIR}"                                 \
                --volume "${HOME}/.${NAME}.bash_history":"${PHOME}/.bash_history" \
                --volume "${HOME}/.${NAME}.viminfo":"${PHOME}/.viminfo"         \
                --volume "${HOME}/.gitconfig":"${PHOME}/.gitconfig"             \
                --volume "${HOME}/.ssh":"${PHOME}/.ssh"                         \
                --volume "${HOME}/.${NAME}.undo_history":"${PHOME}/.undo_history" \
                --hostname ${NAME}                                              \
                --name ${NAME}                                                  \
            ir1ka/vim-ycm${tag:+:${tag}} tail -f /dev/null
