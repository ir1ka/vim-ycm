#!/bin/sh

: "${NAME:=vim-ycm}"
: "${PUSER:=${USER}}"

exec docker exec -it ${NAME} bash -c "exec -l bash"
