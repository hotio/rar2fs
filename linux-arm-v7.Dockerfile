FROM alpine:3.12 as builder

# install
RUN apk add --no-cache autoconf automake fuse-dev g++ make

# https://www.rarlab.com/rar_add.htm
ARG VERSION
ARG UNRARSRC_VERSION=5.9.2

# install packages
RUN tempdir="/rar2fs" && \
    mkdir "${tempdir}" && \
    wget -O - "https://github.com/hasse69/rar2fs/archive/v${VERSION}.tar.gz" | tar xzf - -C "${tempdir}" --strip-components=1 && \
    wget -O - "https://www.rarlab.com/rar/unrarsrc-${UNRARSRC_VERSION}.tar.gz" | tar xzf - -C "${tempdir}" && \
    cd "${tempdir}/unrar" && \
    make lib && \
    cd "${tempdir}" && \
    autoreconf -f -i && \
    ./configure && make


FROM alpine@sha256:db5f021b29ec8fcf605f00d2aac06345756b0ffbdea0e7994044fe9172619a0a
LABEL maintainer="hotio"
ENV FUSE_THREAD_STACK=2048000
ENTRYPOINT ["rar2fs", "-f", "-o", "auto_unmount"]
RUN apk add --no-cache fuse libstdc++
COPY --from=builder /rar2fs/src/rar2fs /usr/local/bin/rar2fs
