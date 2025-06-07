FROM ghcr.io/wg-easy/wg-easy:14
LABEL maintainer="WG-EASY-BREEZY"

# Используемая версия tun2socks
# https://github.com/xjasonlyu/tun2socks/releases
ARG TUN2SOCKS_RELEASE="v2.6.0-beta"

# Используемая версия shadowsocks-rust
# https://github.com/shadowsocks/shadowsocks-rust/releases
ARG SS_RUST_RELEASE="v1.23.4"


RUN apk add --no-cache curl unzip tar xz-utils base64 bash nano dumb-init
RUN apk --update upgrade --no-cache

WORKDIR /app

# Загрузка shadowsocks-rust sslocal
RUN curl -L -o /tmp/ss.tar.xz https://github.com/shadowsocks/shadowsocks-rust/releases/download/${SS_RUST_RELEASE}/shadowsocks-${SS_RUST_RELEASE}.x86_64-unknown-linux-musl.tar.xz  && \
    mkdir -p /tmp/ss && \
    tar -xf /tmp/ss.tar.xz -C /tmp/ss && \
    mv /tmp/ss/sslocal /app/sslocal && \
    chmod +x /app/sslocal && \
    rm -rf /tmp/ss /tmp/ss.tar.xz

# Альтернатива tun2socks
#RUN curl -L https://github.com/xjasonlyu/tun2socks/releases/download/${TUN2SOCKS_RELEASE}/tun2socks-linux-amd64.zip > tun2socks-linux-amd64.zip;\
#  unzip tun2socks-linux-amd64.zip;\
#  mv tun2socks-linux-amd64 tun2socks;\
#  chmod a+x tun2socks;

# Добавлении таблицы маршрутизации "lip" в /etc/iproute2/rt_tables
RUN mkdir -p /etc/iproute2 && echo "20 lip" >> /etc/iproute2/rt_tables

# Копирование конфига настройки сети sysctl.conf
COPY ./sysctl.conf /etc/sysctl.conf

# Загрузка entrypoint скрипта
RUN curl -L https://raw.githubusercontent.com/jinndi/wg-easy-bash/main/entrypoint.sh > entrypoint.sh
RUN chmod a+x entrypoint.sh

# Назначаем точку входа в приложение
ENTRYPOINT [ "dumb-init", "/app/entrypoint.sh" ]