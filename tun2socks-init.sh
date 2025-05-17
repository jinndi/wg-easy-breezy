#!/bin/sh

set -e

# === Переменные (можно переопределить через ENV) ===
ss_tun_name="${ss_tun_name:-tun0}"
ss_ip="${ss_ip:-0.0.0.0}"
ss_port="${ss_port:-8388}"
ss_password="${ss_password:-your_password}"

# Получаем имя интернет интерфейса по умолчанию, его локальный IP и шлюз
DIF=$(ip route | grep default | awk '{print $5}')
LIP=$(ip a l $DIF | awk '/inet /{ print $2 }' | cut -f1 -d"/")
MIP=$(ip r l | grep "default via" | cut -f3 -d" ")

echo "[tun2socks-init] Local IP: $LIP, Gateway: $MIP"

# === Настройка интерфейса TUN ===
echo "[tun2socks-init] Setting up $ss_tun_name..."
ip tuntap add mode tun dev "$ss_tun_name" 2>/dev/null || true
ip addr add 10.255.0.1/24 dev "$ss_tun_name"
ip link set dev "$ss_tun_name" up

# === Запуск tun2socks в фоне ===
echo "[tun2socks-init] Starting tun2socks..."
nohup tun2socks \
  -interface "$DIF" \
  -device "$ss_tun_name" \
  -proxy "ss://aes-256-gcm:${ss_password}@${ss_ip}:${ss_port}" \
  > /tmp/tun2socks.log 2>&1 &

sleep 1

# === Маршруты ===

# Удаляем дефолтный маршрут через eth0 (DIF)
echo "[tun2socks-init] Removing default route via $DIF..."
ip route del default dev "$DIF" 2>/dev/null || true

# Добавляем маршрут к Shadowsocks-серверу напрямую (иначе туннель сам себя съест)
echo "[tun2socks-init] Adding direct route to $ss_ip..."
ip route add "$ss_ip"/32 via "$MIP" dev "$DIF"

# Устанавливаем дефолт через туннель
echo "[tun2socks-init] Routing all traffic through $ss_tun_name..."
ip route add default dev "$ss_tun_name"
