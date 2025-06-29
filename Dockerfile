FROM ghcr.io/wg-easy/wg-easy:14
LABEL org.opencontainers.image.title="wg-easy-breezy" \
    org.opencontainers.image.description="wg-easy v14 mod" \
    org.opencontainers.image.authors="Jinndi <alncores@gmail.com>" \
    org.opencontainers.image.version="4"

# https://github.com/xjasonlyu/tun2socks/releases
ARG TUN2SOCKS_RELEASE="v2.6.0"

RUN apk add --no-cache curl unzip bash nano dumb-init
RUN apk --update upgrade --no-cache

WORKDIR /app

RUN curl -L https://github.com/xjasonlyu/tun2socks/releases/download/${TUN2SOCKS_RELEASE}/tun2socks-linux-amd64.zip > tun2socks-linux-amd64.zip && \
    unzip tun2socks-linux-amd64.zip && \
    mv tun2socks-linux-amd64 tun2socks && \
    chmod a+x tun2socks

RUN mkdir -p /etc/iproute2 && echo "20 lip" >> /etc/iproute2/rt_tables

COPY ./sysctl.conf /etc/sysctl.conf

COPY ./start.sh start.sh
RUN chmod a+x start.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/app/start.sh"]