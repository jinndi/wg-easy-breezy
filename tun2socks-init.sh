#!/bin/bash
# Скрипт поднятия внутри контейне tun интерфейса прокси shadowsocks через tun2socks

set -e

# Ссылка (SIP002 URI scheme) для полкючение к серверу shadowsocks
SS_LINK="${SS_LINK:-''}"

# Название для прокси интерфейса shadowsocks
SS_TUN_NAME="sstun"

# Извлечение IP сервера из ссылки ss://...@IP:port
SS_IP=$(echo "$SS_LINK" | awk -F'[@:]' '{print $(NF-1)}')

# Получение имени интерфейса по умолчанию
DIF=$(ip route | awk '/default/ {print $5}' | head -n1)

# Получение локального IP адреса на интерфейсе
LIP=$(ip -4 addr show "$DIF" | awk '/inet / {print $2}' | cut -d/ -f1)

# Получение основного шлюза
MIP=$(ip route | awk '/default via/ {print $3}' | head -n1)

# Таблица маршрутизации "lip" в /etc/iproute2/rt_tables
mkdir -p /etc/iproute2
touch /etc/iproute2/rt_tables
grep -q -E '\s+lip$' /etc/iproute2/rt_tables || echo "20 lip" >> /etc/iproute2/rt_tables

# Настройка и поднятие TUN интерфейса
echo "[tun2socks-init] Setting up $SS_TUN_NAME..."
ip tuntap add mode tun dev "$SS_TUN_NAME" || true 
ip addr add 192.168.0.33/24 dev "$SS_TUN_NAME"
ip link set dev "$SS_TUN_NAME"
ip link set dev "$SS_TUN_NAME" up

# Настройка маршрутов
echo "[tun2socks-init] Setting up routing...."
ip route del default dev "$DIF"
ip route add default via "$MIP" dev "$DIF" metric 200
ip rule add from "$LIP" table lip
ip route add default via "$MIP" dev "$DIF" table lip
ip route add "$SS_IP/32" via "$MIP" dev "$DIF"
ip route add default dev "$SS_TUN_NAME" metric 50 

# Запуск tun2socks в фоне
echo "[tun2socks-init] Starting tun2socks..."
nohup tun2socks -interface "$DIF" -device "tun://$SS_TUN_NAME" \
  -proxy "$SS_LINK" > /tmp/tun2socks.log 2>&1 &

echo "[tun2socks-init] Done."

# Запуск основного процесса
echo "[tun2socks-init] Starting wg-easy-ss..."
exec /usr/bin/dumb-init node server/index.mjs