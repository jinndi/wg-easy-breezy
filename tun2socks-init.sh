#!/bin/sh

set -e

# === Переменные ===

# Название для прокси интерфейса shadowsocks
SS_TUN_NAME="${SS_TUN_NAME:-tun0}"

# Ссылка (SIP002 URI scheme) для полкючение к серверу shadowsocks
SS_LINK="${SS_LINK:-''}"

# Извлечение IP сервера из ссылки ss://...@IP:port
SS_IP=$(echo "$SS_LINK" | awk -F'[@:]' '{print $2}')

# Получение имени интерфейса по умолчанию
DIF=$(ip route | awk '/default/ {print $5}' | head -n1)

# Получение локального IP адреса на интерфейсе
LIP=$(ip -4 addr show "$DIF" | awk '/inet / {print $2}' | cut -d/ -f1)

# Получение основного шлюза
MIP=$(ip route | awk '/default via/ {print $3}' | head -n1)

# Проверка всех переменных
for var in SS_LINK SS_IP DIF LIP MIP; do
  [ -n "${!var}" ] || { echo "[tun2socks-init] ❌ Переменная $var не задана"; exit 1; }
done

# Таблица маршрутизации "lip" в /etc/iproute2/rt_tables
mkdir -p /etc/iproute2
touch /etc/iproute2/rt_tables
grep -q -E '\s+lip$' /etc/iproute2/rt_tables || echo "20 lip" >> /etc/iproute2/rt_tables

# Настройка и поднятие TUN интерфейса
echo "[tun2socks-init] Setting up $SS_TUN_NAME..."
ip tuntap add mode tun dev "$SS_TUN_NAME" || true 
ip addr add 192.168.0.33/24 dev "$SS_TUN_NAME"
ip link set dev "$SS_TUN_NAME" mtu 1400
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
  -proxy "ss://aes-128-gcm:${SS_PASSWORD}@${SS_IP}:${SS_PORT}" \
  > /tmp/tun2socks.log 2>&1 &

echo "[tun2socks-init] Done."

exit 0
