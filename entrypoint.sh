#!/bin/bash
set -e

: "${WORKDIR:=$(pwd)}"

VIM_YCM_CONFIG="${WORKDIR}/.vim-ycm"

VIMRC=${HOME}/.vimrc

VIMINFO_PREFIX="set viminfofile="
VIMINFO_SUFFIX="/.viminfo"
PATTERN="(^${VIMINFO_PREFIX}).*(${VIMINFO_SUFFIX}$)"
if grep -qE "${PATTERN}" ${VIMRC}; then
    sed -i -E 's|'"${PATTERN}"'|\1'"${VIM_YCM_CONFIG}"'\2|g' ${VIMRC}
else
    VIMINFO_LINE="${VIMINFO_PREFIX}${VIM_YCM_CONFIG}${VIMINFO_SUFFIX}"
    sed -i -E '$a\\n'"${VIMINFO_LINE}" ${VIMRC}
fi

if [ $# -gt 0 ]; then
    exec "$@"
else
    exec bash -c "exec -l bash"
fi
