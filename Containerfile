FROM debian:bookworm-slim AS build

ARG IMAGE_NAME=tinyproxy
ARG IMAGE_DESCRIPTION="Tinyproxy container image"
ARG IMAGE_URL=https://tinyproxy.github.io
ARG GIT_URL=https://github.com/zyrouge/tinyproxy-container-image
ARG CREATED=1970-01-01T00:00:00Z

ARG TINYPROXY_GIT_URL=https://github.com/tinyproxy/tinyproxy
ARG TINYPROXY_GIT_BRANCH=master
ARG TINYPROXY_VERSION=master
ARG TINYPROXY_REVISION=0
ARG TINYPROXY_LICENSE=GPL-2.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        git \
        libtool \
        perl \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git clone --depth 1 --branch "$TINYPROXY_VERSION" "$TINYPROXY_GIT_URL"

WORKDIR /src/tinyproxy

RUN ./autogen.sh

RUN ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var

RUN make

RUN make install DESTDIR=/out

RUN mkdir -p /out/var/lib/tinyproxy

FROM gcr.io/distroless/base-nossl-debian12

LABEL org.opencontainers.image.title="$IMAGE_NAME" \
      org.opencontainers.image.description="$IMAGE_DESCRIPTION" \
      org.opencontainers.image.url="$IMAGE_URL" \
      org.opencontainers.image.source="$GIT_URL" \
      org.opencontainers.image.version="$TINYPROXY_VERSION" \
      org.opencontainers.image.revision="$TINYPROXY_REVISION" \
      org.opencontainers.image.created="$CREATED" \
      org.opencontainers.image.licenses="$TINYPROXY_LICENSE"

COPY --from=build /out/usr/bin/tinyproxy /usr/bin/tinyproxy
COPY --from=build /out/usr/share/tinyproxy /usr/share/tinyproxy
COPY --from=build /out/var/lib/tinyproxy /var/lib/tinyproxy

EXPOSE 8888

USER 1000:1000

CMD ["/usr/bin/tinyproxy", "-d"]
