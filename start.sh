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

if [ -n "$VLESS_IP" ]; then

LOG_LEVEL="${LOG_LEVEL:-warn}"
PROXY_DNS="${PROXY_DNS:-1.1.1.1}"
TUN_STACK="${TUN_STACK:-system}"

# vless reality
VLESS_IP="${VLESS_IP:-}"
VLESS_PORT="${VLESS_PORT:-443}"
VLESS_ID="${VLESS_ID:-}"
VLESS_FLOW="${VLESS_FLOW:-xtls-rprx-vision}"
VLESS_SNI="${VLESS_SNI:-}"
VLESS_FINGERPRINT="${VLESS_FINGER_PRINT:-chrome}"
VLESS_PUBLIC_KEY="${VLESS_PUBLIC_KEY:-}"
VLESS_SHORT_ID="${VLESS_SHORT_ID:-}"

cat << EOF > /app/singbox.json
{
  "log": {
    "level": "${LOG_LEVEL}",
    "timestamp": false
  },
  "dns": {
    "servers": [
      {
        "tag": "dns-proxy",
        "type": "tls",
        "server": "${PROXY_DNS}"
      }
    ],
    "strategy": "prefer_ipv4"
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "interface_name": "tun0",
      "mtu": 1500,
      "address": "172.18.0.1/30",
      "auto_route": true,
      "auto_redirect": true,
      "strict_route": true,
      "stack": "${TUN_STACK}"
    }
  ],
  "outbounds": [
    {
      "tag": "vless-out",
      "type": "vless",
      "server": "${VLESS_IP}",
      "server_port": ${VLESS_PORT},
      "uuid": "${VLESS_ID}",
      "flow": "${VLESS_FLOW}",
      "packet_encoding": "xudp",
      "tls": {
        "enabled": true,
        "insecure": false,
        "server_name": "${VLESS_SNI}",
        "utls": {
          "enabled": true,
          "fingerprint": "${VLESS_FINGERPRINT}"
        },
        "reality": {
          "enabled": true,
          "public_key": "${VLESS_PUBLIC_KEY}",
          "short_id": "${VLESS_SHORT_ID}"
        }
      }
    },
    {
      "type": "direct",
      "tag": "direct"
    }
  ],
  "route": {
    "auto_detect_interface": true,
    "default_domain_resolver": "dns-proxy",
    "final": "vless-out",
    "rules": [
      {
        "action": "sniff"
      },
      {
        "protocol": "dns",
        "action": "hijack-dns"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      }
    ]
  },
  "experimental": {
    "cache_file": {
      "enabled": true
    }
  }
}
EOF

echo "[start.sh] sing-box check cofig"
sing-box check -c /app/singbox.json --disable-color || {
  echo "[start.sh] sing-box cofig error" && exit 1
}

echo "[start.sh] Launch sing-box proxy to $VLESS_IP"
nohup sing-box run -c /app/singbox.json --disable-color  2>&1 &
fi

echo "[start.sh] Launch WEB UI server wg-easy"
exec node /app/server.js