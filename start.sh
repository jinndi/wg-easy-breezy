#!/bin/bash

set -e

for module in tcp_hybla tcp_bbr; do
  if modprobe -q "$module"; then
    echo "[start.sh] Module $module loaded"
  else
    echo "[start.sh] Module loading error $module"
  fi
done

/sbin/sysctl -p > /dev/null 2>&1

if [ -n "$XRAY_IP" ]; then
  TUN_NAME="${WG_DEVICE:-tun0}"
  XRAY_CONTAINER="${XRAY_CONTAINER:-xray}"
  XRAY_PORT="${XRAY_PORT:-10800}"
  DIF=$(ip route | awk '/default/ {print $5}' | head -n1)
  LIP=$(ip -4 addr show "$DIF" | awk '/inet / {print $2}' | cut -d/ -f1)
  MIP=$(ip route | awk '/default via/ {print $3}' | head -n1)

  echo "[start.sh] Configure $TUN_NAME interface..."
  ip tuntap add dev "$TUN_NAME" mode tun 2>/dev/null || true
  ip addr add 192.168.0.33/24 dev "$TUN_NAME"
  ip link set "$TUN_NAME" up

  echo "[start.sh] Configure ip routing...."
  ip route del default dev "$DIF"
  ip route add default via "$MIP" dev "$DIF" metric 200
  ip rule add from "$LIP" table lip
  ip route add default via "$MIP" dev "$DIF" table lip
  ip route add "$XRAY_IP/32" via "$MIP" dev "$DIF"
  ip route add default dev "$TUN_NAME" metric 50 

  echo "[start.sh] Launch tun2socks proxy to $XRAY_IP..."
  nohup /app/tun2socks -proxy "socks5://$XRAY_CONTAINER:$XRAY_PORT" \
  -interface "$DIF" -device "tun://$TUN_NAME" \
  -loglevel "error" > /app/tun2socks.log 2>&1 &
fi

echo "[start.sh] Launch WEB UI server wg-easy..."
exec node /app/server.js