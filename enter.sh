#!/bin/sh

: "${NAME:=vim-ycm}"

exec docker exec -it -u "$(id -u):$(id -g)" ${NAME} bash -c "exec -l bash"
