#!/bin/sh

: "${NAME:=vim-ycm}"

exec docker exec -it ${NAME} bash -c "exec -l bash"
