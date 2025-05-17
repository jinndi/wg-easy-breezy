#!/bin/sh

set -e

# === Переменные ===
SS_TUN_NAME="${SS_TUN_NAME:-tun0}"
SS_IP="${SS_IP:-0.0.0.0}"
SS_PORT="${SS_PORT:-8388}"
SS_PASSWORD="${SS_PASSWORD:-your_password}"
DIF=$(ip route | grep default | awk '{print $5}')
LIP=$(ip a l $DIF | awk '/inet /{ print $2 }' | cut -f1 -d"/")
MIP=$(ip r l | grep "default via" | cut -f3 -d" ")

# TUN интерфейс
echo "[tun2socks-init] Setting up $SS_TUN_NAME..."
ip tuntap add mode tun dev "$SS_TUN_NAME" 2>/dev/null || true
ip addr add 192.168.0.33/24 dev "$SS_TUN_NAME"
ip link set dev "$SS_TUN_NAME" up

# Маршруты
echo "[tun2socks-init] Setting up routing...."
ip route del default dev "$DIF" 2>/dev/null || true
ip route add default via "$MIP" dev "$DIF" metric 200
ip rule add from "$LIP" table lip
ip route add default via "$MIP" dev "$DIF" table lip
ip route add "$SS_IP/32" via "$MIP" dev "$DIF"
ip route add default dev "$SS_TUN_NAME" metric 50

# Запуск tun2socks в фоне
echo "[tun2socks-init] Starting tun2socks..."
nohup tun2socks \
  -interface "$DIF" \
  -device "tun://$SS_TUN_NAME" \
  -proxy "ss://aes-256-gcm:${SS_PASSWORD}@${SS_IP}:${SS_PORT}" \
  > /tmp/tun2socks.log 2>&1 &

echo "[tun2socks-init] Done. Sleeping to allow tun2socks to initialize..."
sleep 2
