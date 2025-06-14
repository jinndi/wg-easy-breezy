#!/bin/bash

set -e

# Загрузка модулей tcp_congestion_control
for module in tcp_hybla tcp_bbr; do
  if modprobe -q "$module"; then
    echo "[start.sh] Модуль $module загружен"
  else
    echo "[start.sh] Ошибка загрузки модуля $module"
  fi
done

# Применяем сетевые настройки из /etc/sysctl.conf
/sbin/sysctl -p > /dev/null 2>&1

# Если SS_LINK (Ссылка SIP002 URI scheme для полкючение к серверу shadowsocks) не пуста
if [ -n "$SS_LINK" ]; then

  # Добавляем префикс ss:// к ссылки подключения, если его нет
  [[ "$SS_LINK" != ss://* ]] && SS_LINK="ss://${SS_LINK}"

  # Название для прокси интерфейса shadowsocks
  SS_TUN_NAME="${SS_TUN_NAME:-tun0}"

  # Извлечение IP сервера из ссылки ss://...@IP:port
  SS_IP=$(echo "$SS_LINK" | awk -F'[@:]' '{print $(NF-1)}')

  # Получение имени интерфейса по умолчанию
  DIF=$(ip route | awk '/default/ {print $5}' | head -n1)

  # Получение локального IP адреса на интерфейсе
  LIP=$(ip -4 addr show "$DIF" | awk '/inet / {print $2}' | cut -d/ -f1)

  # Получение основного шлюза
  MIP=$(ip route | awk '/default via/ {print $3}' | head -n1)

  # Настройка и поднятие TUN интерфейса
  echo "[start.sh] Настраиваем $SS_TUN_NAME интерфейс..."
  ip tuntap add dev "$SS_TUN_NAME" mode tun 2>/dev/null || true
  ip addr add 192.168.0.33/24 dev "$SS_TUN_NAME"
  ip link set "$SS_TUN_NAME" up

  # Настройка маршрутов
  echo "[start.sh] Настраиваем ip routing...."
  ip route del default dev "$DIF"
  ip route add default via "$MIP" dev "$DIF" metric 200
  ip rule add from "$LIP" table lip
  ip route add default via "$MIP" dev "$DIF" table lip
  ip route add "$SS_IP/32" via "$MIP" dev "$DIF"
  ip route add default dev "$SS_TUN_NAME" metric 50 

  # Запускаем прокси shadowsocks через tun2socks
  echo "[start.sh] Запускаем tun2socks proxy к $SS_IP..."
  nohup /app/tun2socks -proxy "$SS_LINK" -interface "$DIF" -device "tun://$SS_TUN_NAME" \
    -tcp-rcvbuf 1048576 -tcp-sndbuf 1048576 -loglevel "error" > /app/tun2socks.log 2>&1 &
fi

# Запуск сервера wg-easy
echo "[start.sh] Запускаем WEB UI сервер wg-easy..."
exec node /app/server.js