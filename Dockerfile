FROM ghcr.io/wg-easy/wg-easy:14
LABEL maintainer="WG-EASY-BASH"

# Используемая версия tun2socks
ARG TUN2SOCKS_RELEASE="v2.6.0-beta"

RUN apk add --no-cache curl unzip bash dumb-init
RUN apk --update upgrade --no-cache

WORKDIR /app

# Загрузка tun2socks
RUN curl -L https://github.com/xjasonlyu/tun2socks/releases/download/${TUN2SOCKS_RELEASE}/tun2socks-linux-amd64.zip > tun2socks-linux-amd64.zip;\
  unzip tun2socks-linux-amd64.zip;\
  mv tun2socks-linux-amd64 tun2socks;\
  chmod a+x tun2socks;

# Добавлении таблицы маршрутизации "lip" в /etc/iproute2/rt_tables
RUN mkdir -p /etc/iproute2 && echo "20 lip" >> /etc/iproute2/rt_tables

# Копирование конфига настройки сети sysctl.conf
COPY ./sysctl.conf /etc/sysctl.conf

# nofile 51200 для всех пользователей
RUN mkdir -p /etc/security && \
  echo -e " \n\
  * soft nofile 51200 \n\
  * hard nofile 51200 \n\
  " | sed -e 's/^\s\+//g' | tee -a /etc/security/limits.conf

# Загрузка конфига настройки сети sysctl.conf
RUN curl -L https://raw.githubusercontent.com/jinndi/wg-easy-bash/main/entrypoint.sh > entrypoint.sh
RUN chmod a+x start.sh

# Назначаем точку входа в приложение
ENTRYPOINT [ "dumb-init", "/app/entrypoint.sh" ]