#!/bin/sh

set -e

# === Переменные (можно переопределить через ENV) ===
SS_TUN_NAME="${SS_TUN_NAME:-tun0}"
SS_IP="${SS_IP:-0.0.0.0}"
SS_PORT="${SS_PORT:-8388}"
SS_PASSWORD="${SS_PASSWORD:-your_password}"

# Получаем имя интернет интерфейса по умолчанию, его локальный IP и шлюз
DIF=$(ip route | grep default | awk '{print $5}')
LIP=$(ip a l $DIF | awk '/inet /{ print $2 }' | cut -f1 -d"/")
MIP=$(ip r l | grep "default via" | cut -f3 -d" ")

echo "[tun2socks-init] Local IP: $LIP, Gateway: $MIP"

# === Настройка интерфейса TUN ===
echo "[tun2socks-init] Setting up $SS_TUN_NAME..."
ip tuntap add mode tun dev "$SS_TUN_NAME" 2>/dev/null || true
ip addr add 10.255.0.1/24 dev "$SS_TUN_NAME"
ip link set dev "$SS_TUN_NAME" up

# === Запуск tun2socks в фоне ===
echo "[tun2socks-init] Starting tun2socks..."
nohup tun2socks \
  -interface "$DIF" \
  -device "$SS_TUN_NAME" \
  -proxy "ss://aes-256-gcm:${SS_PASSWORD}@${SS_IP}:${SS_PORT}" \
  > /tmp/tun2socks.log 2>&1 &

sleep 1

# === Маршруты ===

# Удаляем дефолтный маршрут через eth0 (DIF)
echo "[tun2socks-init] Removing default route via $DIF..."
ip route del default dev "$DIF" 2>/dev/null || true

# Добавляем маршрут к Shadowsocks-серверу напрямую (иначе туннель сам себя съест)
echo "[tun2socks-init] Adding direct route to $SS_IP..."
ip route add "$SS_IP"/32 via "$MIP" dev "$DIF"

# Устанавливаем дефолт через туннель
echo "[tun2socks-init] Routing all traffic through $SS_TUN_NAME..."
ip route add default dev "$SS_TUN_NAME"
