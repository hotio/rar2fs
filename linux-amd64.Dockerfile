ARG BRANCH
FROM hotio/base:${BRANCH}

ARG DEBIAN_FRONTEND="noninteractive"

ENV INPUT_DIR="/input" OUTPUT_DIR="/output"

COPY root/ /

# https://github.com/hasse69/rar2fs/releases
# https://www.rarlab.com/rar_add.htm
ENV RAR2FS_VERSION=1.27.2 UNRARSRC_VERSION=5.8.3

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        fuse \
        libfuse-dev autoconf automake build-essential && \
# install rar2fs
    tempdir="$(mktemp -d)" && \
    curl -fsSL "https://github.com/hasse69/rar2fs/archive/v${RAR2FS_VERSION}.tar.gz" | tar xzf - -C "${tempdir}" --strip-components=1 && \
    curl -fsSL "https://www.rarlab.com/rar/unrarsrc-${UNRARSRC_VERSION}.tar.gz" | tar xzf - -C "${tempdir}" && \
    cd "${tempdir}/unrar" && \
    make lib && make install-lib && \
    cd "${tempdir}" && \
    autoreconf -f -i && \
    ./configure && make && make install && \
    cd ~ && \
    rm -rf "${tempdir}" && \
# clean up
    apt purge -y libfuse-dev autoconf automake build-essential && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
