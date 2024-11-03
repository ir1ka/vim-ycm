ARG TAG=latest

FROM debian:${TAG}

ARG DEBIAN_FRONTEND=noninteractive

# unminimize for support man-db
RUN dpkg --add-architecture i386                                    \
    && dpkg --add-architecture arm64                                \
    && sed -i 's@^\(Components: .*\)$@\1 contrib non-free@g'        \
           /etc/apt/sources.list.d/debian.sources                   \
    && apt-get update                                               \
    && apt-get install -y --no-install-recommends                   \
# apt utils and man-db \
        apt-utils man-db                                            \
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
# cross aarch64/arm64 \
        gcc-aarch64-linux-gnu g++-aarch64-linux-gnu                 \
# cross arm \
        gcc-arm-linux-gnueabi g++-arm-linux-gnueabi                 \
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
# tools \
        bash-completion iproute2 iputils-ping                       \
        subversion git-svn git-cvs exuberant-ctags cscope           \
        coreutils curl wget less file tree                          \
        dos2unix gnupg zip unzip ssh-client lrzsz                   \
        python3-venv                                                \
# i386 runtime \
        libc6:i386 libstdc++6:i386 zlib1g:i386                      \
# arm64 runtime \
        libc6:arm64 libstdc++6:arm64 zlib1g:arm64                   \
# clean \
    && apt-get clean                                                \
    && (rm -rf /var/lib/apt/lists/*                                 \
        /var/tmp/* /var/tmp/.[!.]*                                  \
        /tmp/* /tmp/.[!.]* || true)
# restore bash completion for apt \
#    && (dir=/etc/apt/apt.conf.d;                                    \
#        [ -d $dir ] && sed -i 's/[[:space:]]*Dir::Cache::\(src\)\?pkgcache "";[[:space:]]*//g' $dir/*)  \
# do not clean APT cache \
#    && (f=/etc/apt/apt.conf.d/docker-clean;                         \
#        [ -f $f ] && sed -i 's? /var/cache/apt/\*\.bin??g' $f)

ARG PUSER PUID PGROUPS
ARG PHOME=/home/${PUSER}
ARG PGROUP PGID
ARG WORKDIR=/work

RUN ( [ -z "${PGROUP}" ] || groupadd ${PGID:+--gid ${PGID}}         \
                                     --non-unique ${PGROUP} )       \
    && useradd ${PGROUP:+--gid ${PGROUP} --no-user-group}           \
               ${PGROUPS:+--groups ${PGROUPS}}                      \
               ${PUID:+--uid ${PUID} --non-unique}                  \
               --skel /et/skel                                      \
               --home-dir ${PHOME}                                  \
               --create-home                                        \
               --shell /bin/bash                                    \
               ${PUSER}                                             \
    && install --directory                                          \
               --mode=0755                                          \
               --owner=${PUSER}                                     \
               --group=${PGROUP:-${PUSER}}                          \
               ${WORKDIR}

USER ${PUSER}

RUN cp --preserve=mode,timestamps /etc/skel/.[!.]* ~/               \
    && sed -i 's/^\(\s*\)#alias\b/\1alias/g' ~/.bashrc              \
# clone \
    && git clone https://github.com/Ir1Ka/docker-vim-ycm.git        \
           /tmp/vim-ycm                                             \
    && (cd /tmp/vim-ycm/ && cp .vimrc home-cfg/.[!.]* ~/)           \
    && rm -rf /tmp/vim-ycm                                          \
# install vim plugin and compile ycm \
    && git clone https://github.com/VundleVim/Vundle.vim.git        \
           ~/.vim/bundle/Vundle.vim                                 \
    && echo "Vundle plugin installing ..."                          \
    && echo | vim +PluginInstall +qall >/dev/null 2>&1              \
    && (cd ~/.vim/bundle/YouCompleteMe && python3 install.py --all) \
    && rm -rf ~/.cache                                              \
# environments \
    && sed -i 's|^\(set undodir=\)~\(/.undo_history.*\)$|\1'"${WORKDIR}"'\2|g' \
           ~/.vimrc                                                 \
    && sed -i '$a\\nset viminfofile='"${WORKDIR}"'/.viminfo'        \
           ~/.vimrc                                                 \
    && for f in ~/.*-append; do                                     \
        _f=${f%-append};                                            \
        if [ -r "${f}" ]; then                                      \
            if [ -w "${_f}" ]; then                                 \
                cat "${f}" >> "${_f}";                              \
            elif [ ! -e "${_f}" -a -w "${f%/*}" ]; then             \
                cp "${f}" "${_f}";                                  \
            fi;                                                     \
        fi;                                                         \
    done                                                            \
    && rm -f ~/.*-append

ENV XDG_CONFIG_HOME ${WORKDIR}
ENV LANG C.UTF-8
WORKDIR ${WORKDIR}
VOLUME ${WORKDIR}

VOLUME ${PHOME}/.bash_history

CMD [ "bash", "-" ]
