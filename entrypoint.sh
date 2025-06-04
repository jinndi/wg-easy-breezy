#!/bin/bash

set -e

# Если SS_LINK (Ссылка SIP002 URI scheme для полкючение к серверу shadowsocks) не пуста
if [ -n "$SS_LINK" ]; then

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
  echo "[entrypoint.sh] Настраиваем $SS_TUN_NAME интерфейс..."
  ip tuntap add mode tun dev "$SS_TUN_NAME" || true 
  ip addr add 192.168.0.33/24 dev "$SS_TUN_NAME"
  ip link set dev "$SS_TUN_NAME"
  ip link set dev "$SS_TUN_NAME" up

  # Настройка маршрутов
  echo "[entrypoint.sh] Настраиваем ip routing...."
  ip route del default dev "$DIF"
  ip route add default via "$MIP" dev "$DIF" metric 200
  ip rule add from "$LIP" table lip
  ip route add default via "$MIP" dev "$DIF" table lip
  ip route add "$SS_IP/32" via "$MIP" dev "$DIF"
  ip route add default dev "$SS_TUN_NAME" metric 50 

  # Запуск tun2socks в фоне
  echo "[entrypoint.sh] Запускаем tun2socks proxy к $SS_IP..."
  nohup /app/tun2socks -interface "$DIF" -device "tun://$SS_TUN_NAME" \
    -proxy "$SS_LINK" > /app/tun2socks.log 2>&1 &
fi

# Запуск сервера wg-easy
echo "[entrypoint.sh] Запускаем WEB UI сервер wg-easy..."
exec /usr/bin/dumb-init node /app/server.js