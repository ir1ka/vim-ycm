ARG TAG=latest
ARG DISTRO=ubuntu

FROM ${DISTRO}:${TAG}

ARG DISTRO
ARG DEBIAN_FRONTEND=noninteractive

# unminimize for support man-db
RUN --mount=type=cache,target=/root/.cache                          \
    --mount=type=cache,target=/var/lib/apt                          \
    apt-get update                                                  \
    && apt-get install -y --no-install-recommends                   \
# apt utils and man-db \
        apt-utils man-db                                            \
        ubuntu-minimal                                              \
        unminimize                                                  \
    && (yes | unminimize)                                           \
    && apt-get install -y --no-install-recommends                   \
# vim and ycm's dependency library \
        build-essential cmake vim-nox python3-dev                   \
        mono-complete golang nodejs default-jdk npm                 \
# develop \
        ninja-build automake libtool gdb gettext                    \
        gnu-standards autopoint                                     \
        python-is-python3 repo                                      \
        libnuma-dev                                                 \
        libcunit1-dev libgnutls28-dev                               \
# RDMA develop \
        libibverbs-dev librdmacm-dev                                \
# clang \
        clang clang-format clang-tidy clang-tools clangd            \
# cross aarch64/arm64 \
        gcc-aarch64-linux-gnu g++-aarch64-linux-gnu                 \
# cross arm \
        gcc-arm-linux-gnueabi g++-arm-linux-gnueabi                 \
        gcc-arm-none-eabi                                           \
# cross armhf \
        gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf             \
# cross mips64 \
        gcc-mips64-linux-gnuabi64 g++-mips64-linux-gnuabi64         \
# cross riscv \
        # with glibc \
        gcc-riscv64-linux-gnu g++-riscv64-linux-gnu                 \
        # with newlib \
        gcc-riscv64-unknown-elf                                     \
# linux kernel compile tools \
        git fakeroot libncurses-dev xz-utils libssl-dev bc flex     \
        libelf-dev bison gawk openssl dkms libudev-dev libpci-dev   \
        libiberty-dev autoconf device-tree-compiler                 \
# buildroot compile tools \
        cpio rsync                                                  \
# RT-Thread compile tools \
        scons python3-requests                                      \
# openCL and X11 devel \
        libx11-dev mesa-common-dev                                  \
# qemu \
        libglib2.0-dev libpixman-1-dev libepoxy-dev                 \
# tools \
        bash-completion iproute2 iputils-ping                       \
        subversion git-svn git-cvs exuberant-ctags cscope           \
        coreutils curl wget less file tree                          \
        dos2unix gnupg zip unzip ssh-client lrzsz                   \
        python3-full python3-venv                                   \
        python3-setuptools python3-stdeb                            \
        python3-distutils-extra python3-pyqt-distutils              \
        python3-distlib python3-pyelftools                          \
        dosfstools mtools swig                                      \
        jq

ARG PUSER=coder
ARG PUID=1000
ARG PGROUPS
ARG PHOME=/config
ARG PGROUP PGID
ARG WORKDIR=/work

RUN ( [ -z "${PGROUP}" ] || groupadd ${PGID:+--gid ${PGID}}         \
                                     --non-unique ${PGROUP} )       \
    &&                                                              \
    (if test -n "${PUID}" && id -un ${PUID}; then                   \
       usermod --move-home                                          \
               --home ${PHOME}                                      \
               --login ${PUSER}                                     \
               $(id -un ${PUID});                                   \
     else                                                           \
       useradd ${PGROUP:+--gid ${PGROUP} --no-user-group}           \
               ${PGROUPS:+--groups ${PGROUPS}}                      \
               --uid ${PUID} --non-unique                           \
               --skel /et/skel                                      \
               --home-dir ${PHOME}                                  \
               --create-home                                        \
               --shell /bin/bash                                    \
               ${PUSER};                                            \
     fi)                                                            \
    && install --directory                                          \
               --mode=0755                                          \
               --owner=${PUSER}                                     \
               --group=${PGROUP:-$(id -gn ${PUSER})}                \
               ${WORKDIR}

USER ${PUSER}

RUN --mount=type=bind,source=./cfg,target=/cfg,ro                   \
    cp -a --no-preserve=ownership,links /cfg/. ~/

RUN --mount=type=cache,target=/config/.cache,uid=${PUID}            \
    cp --preserve=mode,timestamps /etc/skel/.[!.]* ~/               \
    && sed -E -i 's/^(\s*)#\s*(alias\s+)/\1\2/g' ~/.bashrc          \
# install vim plugin and compile ycm \
    && git clone https://github.com/VundleVim/Vundle.vim.git        \
           ~/.vim/bundle/Vundle.vim                                 \
    && echo "Vundle plugin installing ..."                          \
    && (yes '' | vim +PluginInstall +qall >/dev/null 2>&1)          \
    && (cd ~/.vim/bundle/YouCompleteMe && python3 install.py --all) \
# python3 venv \
    && python3 -m venv ~/.venv                                      \
    && ~/.venv/bin/python3 -m pip install --no-cache-dir            \
        setuptools pyelftools pyqt-distutils distlib stdeb requests \
        distutils-extra-python                                      \
        compiledb

RUN --mount=type=bind,source=./append,target=/append,ro             \
# environments \
    for f in /append/.*; do                                         \
        _f=${f##*/};                                                \
        if [ -r "${f}" ]; then                                      \
            if [ -w ~/"${_f}" ]; then                               \
                cat "${f}" >> ~/"${_f}";                            \
            elif [ ! -e ~/"${_f}" ]; then                           \
                cp "${f}" ~/"${_f}";                                \
            else                                                    \
                echo ~/"${_f}" exists but is not writable, IGNORE.; \
            fi;                                                     \
        fi;                                                         \
    done

ENV TERM=xterm-color
ENV XDG_CONFIG_HOME=${WORKDIR}
ENV LANG=C.UTF-8

WORKDIR ${WORKDIR}
#VOLUME ${WORKDIR}
#VOLUME ${PHOME}/.bash_history

COPY --chown=root:root --chmod=0755 ./entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "tail", "-f", "/dev/null" ]

USER root
ENV OUID=${PUID}
ENV DUID=${PUID}
#ENV DGID=

LABEL org.opencontainers.image.source="https://github.com/ir1ka/vim-ycm"
LABEL org.opencontainers.image.description="vim with ycmd container image"
LABEL org.opencontainers.image.licenses=MIT
