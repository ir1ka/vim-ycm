#!/bin/bash
set -e

: "${DUID:="${OUID}"}"

if [ "$(id -u)" -eq 0                       \
     -a -n "${OUID}" -a "${OUID}" -ne 0     \
     -a -n "${DUID}" -a "${DUID}" -ne 0 ]
then
    if getent passwd "${DUID}"; then
        DUSER="$(getent passwd "${DUID}" | cut -d: -f1)"
    else
        DUSER="$(id -un "${OUID}")"
        #DHOME="$(getent passwd "${OUID}" | cut -d: -f6)"
        DHOME="$(eval echo "~${DUSER}")"
        DGROUP="$(id -gn "${DUSER}")"

        usermod -u "${DUID}" "${DUSER}"
        [ -z "${DGID}" ] || groupmod -g "${DUID}" "${DGROUP}"

        find "${DHOME}" -uid "${DUID}" -prune -o        \
                        -uid "${OUID}"                  \
                        -exec chown "${DUID}${DGID:+:${DGID}}" {} \;
    fi

    exec su -c 'exec "${SHELL}" "$0" "$@"'  \
            -- "${DUSER}" "$0" "$@"
fi

: "${WORKDIR:=$(pwd)}"

VIM_YCM_CONFIG="${WORKDIR}/.vim-ycm"

VIMRC=${HOME}/.vimrc

VIMINFO_PREFIX="set viminfofile="
VIMINFO_SUFFIX="/viminfo"
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
