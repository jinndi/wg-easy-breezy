#!/bin/bash

set -e

for module in tcp_hybla tcp_bbr; do
  if modprobe -q "$module"; then
    echo "[start.sh] Module $module loaded"
  else
    echo "[start.sh] Module $module loading error"
  fi
done

/sbin/sysctl -p >/dev/null 2>&1

if [ -n "$VLESS_IP" ]; then

# Paths
PATH_SINGBOX_CONFIG="/app/singbox.json"
PATH_SINGBOX_LOG="/app/singbox.log"

# sing-box
SB_LOG_LEVEL="${SB_LOG_LEVEL:-warn}"
SB_DNS_PROXY="${SB_DNS_PROXY:-1.1.1.1}"
SB_TUN_STACK="${SB_TUN_STACK:-system}"

## Do not use proxy for specified rules
# GEOSITE https://github.com/SagerNet/sing-geosite/tree/rule-set
# Example: category-ru,cn,speedtest
SB_GEOSITE_BYPASS="${SB_GEOSITE_BYPASS:-}"
# GEOIP https://github.com/SagerNet/sing-geoip/tree/rule-set
# Example: ru,by,cn,ir
SB_GEOIP_BYPASS="${SB_GEOIP_BYPASS:-}"

# VLESS Reality
VLESS_IP="${VLESS_IP:-}"
VLESS_PORT="${VLESS_PORT:-443}"
VLESS_ID="${VLESS_ID:-}"
VLESS_FLOW="${VLESS_FLOW:-xtls-rprx-vision}"
VLESS_SNI="${VLESS_SNI:-}"
VLESS_FINGERPRINT="${VLESS_FINGER_PRINT:-chrome}"
VLESS_PUBLIC_KEY="${VLESS_PUBLIC_KEY:-}"
VLESS_SHORT_ID="${VLESS_SHORT_ID:-}"

cat << EOF > "$PATH_SINGBOX_CONFIG"
{
  "log": {
    "level": "${SB_LOG_LEVEL}",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "dns-proxy",
        "type": "tls",
        "server": "${SB_DNS_PROXY}",
        "detour": "vless-out"
      },
      {
        "tag": "dns-local",
        "type": "local",
        "detour": "direct-out"
      }
    ],
    "strategy": "prefer_ipv4"
  },
  "inbounds": [
    {
      "tag": "tun-in",
      "type": "tun",
      "interface_name": "tun0",
      "mtu": 1500,
      "address": "172.18.0.1/30",
      "auto_route": true,
      "auto_redirect": true,
      "strict_route": true,
      "stack": "${SB_TUN_STACK}"
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
      "domain_resolver": "dns-proxy",
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
      "tag": "direct-out",
      "type": "direct",
      "domain_resolver": "dns-local"
    }
  ],
  "route": {
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
        "outbound": "direct-out"
      },
      {
        "rule_set": "category-ads-all",
        "action": "reject"
      }
    ],
    "rule_set": [
      {
        "tag": "category-ads-all",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ads-all.srs",
        "download_detour": "vless-out",
        "update_interval": "1d"
      }
    ],
    "final": "vless-out",
    "auto_detect_interface": true,
    "default_domain_resolver": "dns-proxy"
  },
  "experimental": {
    "cache_file": {
      "enabled": true,
      "path": "/etc/wireguard/singbox.db"
    }
  }
}
EOF

mergeconf() {
  local patch_file="$1"
  local tmpout
  tmpout=$(mktemp 2>/dev/null)

  if ! sing-box merge "$tmpout" \
    -c "$PATH_SINGBOX_CONFIG" -c "$patch_file" \
    >/dev/null 2>&1; 
  then
    echo "[start.sh] sing-box merge config error"
    rm -f "$patch_file" "$tmpout"
    exit 1
  fi

  mv "$tmpout" "$PATH_SINGBOX_CONFIG"
  rm -f "$patch_file"
}

gen_rules() {
  local type="$1" # geosite or geoip
  local list="$2"
  local -n first_rule_ref="$3"
  local -n first_rs_ref="$4"

  IFS=',' read -ra entries <<< "$list"
  for entry in "${entries[@]}"; do
    if [ "$first_rule_ref" = true ]; then
      first_rule_ref=false
    else
      echo ","
    fi
    echo -n "{\"rule_set\":\"${type}-${entry}\",\"outbound\":\"direct-out\"}"
  done
}

gen_rule_sets() {
  local type="$1" # geosite or geoip
  local list="$2"
  local -n first_rule_ref="$3"
  local -n first_rs_ref="$4"

  IFS=',' read -ra entries <<< "$list"
  for entry in "${entries[@]}"; do
    if [ "$first_rs_ref" = true ]; then
      first_rs_ref=false
    else
      echo ","
    fi
    local base_url
    if [ "$type" = "geosite" ]; then
      base_url="https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-${entry}.srs"
    else
      base_url="https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-${entry}.srs"
    fi

    echo -n "{\"tag\":\"${type}-${entry}\",\"type\":\"remote\",\"format\":\"binary\",\"url\":\"${base_url}\",\"download_detour\":\"vless-out\",\"update_interval\":\"1d\"}"
  done
}

add_all_rule_sets() {
  if [ -z "$SB_GEOSITE_BYPASS" ] && [ -z "$SB_GEOIP_BYPASS" ]; then
    return
  fi

  echo "[start.sh] sing-box add route rules"

  local tmpfile
  tmpfile=$(mktemp 2>/dev/null)

  local first_rule=true
  local first_rs=true

  {
    echo '{"route":{"rules":['

    [ -n "$SB_GEOSITE_BYPASS" ] && gen_rules geosite "$SB_GEOSITE_BYPASS" first_rule first_rs
    [ -n "$SB_GEOIP_BYPASS" ] && gen_rules geoip "$SB_GEOIP_BYPASS" first_rule first_rs

    echo '],"rule_set":['

    # shellcheck disable=SC2034
    first_rule=true
    # shellcheck disable=SC2034
    first_rs=true

    [ -n "$SB_GEOSITE_BYPASS" ] && gen_rule_sets geosite "$SB_GEOSITE_BYPASS" first_rule first_rs
    [ -n "$SB_GEOIP_BYPASS" ] && gen_rule_sets geoip "$SB_GEOIP_BYPASS" first_rule first_rs

    echo ']}}'
  } > "$tmpfile"

  mergeconf "$tmpfile"
}
 
add_all_rule_sets

echo "[start.sh] sing-box check config"
sing-box check -c "$PATH_SINGBOX_CONFIG" >/dev/null 2>&1 || {
  echo "[start.sh] sing-box config syntax error" && exit 1
}

echo "[start.sh] sing-box format config"
sing-box format -w -c "$PATH_SINGBOX_CONFIG" >/dev/null 2>&1 || {
  echo "[start.sh] sing-box config formatting error" && exit 1
}

echo "[start.sh] Launch sing-box proxy to $VLESS_IP"
nohup sing-box run -c "$PATH_SINGBOX_CONFIG" \
  --disable-color > "$PATH_SINGBOX_LOG" 2>&1 &
fi

echo "[start.sh] Launch WEB UI server wg-easy"
exec node /app/server.js