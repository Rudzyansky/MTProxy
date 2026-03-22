# syntax=docker/dockerfile:1.7

FROM oraclelinux:8 AS build

RUN dnf -y install \
      gcc \
      make \
      git \
      binutils \
      glibc-devel \
      openssl-devel \
      zlib-devel && \
    dnf clean all

WORKDIR /src
COPY . .

RUN make clean && make -j"$(nproc)"

ARG TARGETARCH
RUN if [ "${TARGETARCH}" = "arm64" ]; then \
      readelf -h objs/bin/mtproto-proxy | grep -q "Machine:.*AArch64"; \
    fi

FROM scratch AS artifact
COPY --from=build /src/objs/bin/mtproto-proxy /mtproto-proxy
