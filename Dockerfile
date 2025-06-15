FROM ghcr.io/wg-easy/wg-easy:14
LABEL maintainer="WG-EASY-BREEZY"

# Используемая версия tun2socks
# https://github.com/xjasonlyu/tun2socks/releases
ARG TUN2SOCKS_RELEASE="v2.6.0"

RUN apk add --no-cache curl unzip bash nano dumb-init
RUN apk --update upgrade --no-cache

WORKDIR /app

# Загрузка tun2socks
RUN curl -L https://github.com/xjasonlyu/tun2socks/releases/download/${TUN2SOCKS_RELEASE}/tun2socks-linux-amd64.zip > tun2socks-linux-amd64.zip && \
    unzip tun2socks-linux-amd64.zip && \
    mv tun2socks-linux-amd64 tun2socks && \
    chmod a+x tun2socks

# Добавлении таблицы маршрутизации "lip" в /etc/iproute2/rt_tables
RUN mkdir -p /etc/iproute2 && echo "20 lip" >> /etc/iproute2/rt_tables

# Копирование конфига настройки сети sysctl.conf
COPY ./sysctl.conf /etc/sysctl.conf

# Копирование entrypoint.sh скрипта
COPY ./start.sh start.sh
RUN chmod a+x start.sh

# Устанавливаем dumb-init как init-процесс (PID 1)
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Команда при запуске контейнера
CMD ["/app/start.sh"]