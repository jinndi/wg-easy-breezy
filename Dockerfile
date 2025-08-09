# https://github.com/SagerNet/sing-box/releases
ARG SINGBOX_VERSION="v1.12.0"

FROM ghcr.io/sagernet/sing-box:${SINGBOX_VERSION} AS sing-box

FROM ghcr.io/wg-easy/wg-easy:14

LABEL org.opencontainers.image.title="wg-easy-breezy" \
    org.opencontainers.image.description="wg-easy v14 mod" \
    org.opencontainers.image.authors="Jinndi <alncores@gmail.com>" \
    org.opencontainers.image.version="8"

WORKDIR /app

RUN apk add --no-cache bash nano dumb-init

COPY --from=sing-box /usr/local/bin/sing-box /bin/sing-box

COPY ./sysctl.conf /etc/sysctl.conf

COPY ./start.sh start.sh

RUN chmod a+x start.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/app/start.sh"]