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

PATH_SINGBOX_CONFIG="/app/singbox.json"
PATH_SINGBOX_LOG="/app/singbox.log"

LOG_LEVEL="${LOG_LEVEL:-warn}"

DNS_PROXY="${DNS_PROXY:-1.1.1.1}"
DNS_DIRECT="${DNS_DIRECT:-77.88.8.8}"

## Rules for bypassing proxies
# GEOSITE https://github.com/SagerNet/sing-geosite/tree/rule-set
# Example: category-ru,cn,speedtest
GEOSITE_BYPASS="${GEOSITE_BYPASS:-}"
# GEOIP https://github.com/SagerNet/sing-geoip/tree/rule-set
# Example: ru,by,cn,ir
GEOIP_BYPASS="${GEOIP_BYPASS:-}"

## VLESS Reality
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
    "level": "${LOG_LEVEL}",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "dns-proxy",
        "type": "tls",
        "server": "${DNS_PROXY}",
        "detour": "proxy"
      },
      {
        "tag": "dns-direct",
        "type": "tls",
        "server": "${DNS_DIRECT}",
        "detour": "direct"
      }
    ],
    "rules": [     
      {
        "rule_set": "category-ads-all",
        "action": "reject"
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
      "stack": "system"
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
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
      "tag": "direct",
      "type": "direct"
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
        "outbound": "direct"
      }
    ],
    "rule_set": [
      {
        "tag": "category-ads-all",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ads-all.srs",
        "download_detour": "proxy",
        "update_interval": "1d"
      }
    ],
    "final": "proxy",
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
  local type="$1" # dns or route
  local prefix="$2" # geosite or geoip
  local list="$3"
  local -n first_rule_ref="$4"

  local output=""

  IFS=',' read -ra entries <<< "$list"
  for rule in "${entries[@]}"; do
    if [ "$first_rule_ref" = true ]; then
      first_rule_ref=false
    else
      output+=","
    fi

    output+="{\"rule_set\":\"${prefix}-${rule}\","

    case "$type" in
      "dns")
        output+='"server":"dns-direct"}'
      ;;
      "route")
        output+='"outbound":"direct"}'
      ;;
    esac 
  done

  echo -n "$output"
}

gen_rule_sets() {
  local prefix="$1" # geosite or geoip
  local list="$2"
  local -n first_rule_ref="$3"

  IFS=',' read -ra entries <<< "$list"
  for rule in "${entries[@]}"; do
    if [ "$first_rule_ref" = true ]; then
      first_rule_ref=false
    else
      echo ","
    fi
    local base_url
    if [ "$prefix" = "geosite" ]; then
      base_url="https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-${rule}.srs"
    else
      base_url="https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-${rule}.srs"
    fi

    echo -n "{\"tag\":\"${prefix}-${rule}\",\"type\":\"remote\",\"format\":\"binary\",\"url\":\"${base_url}\",\"download_detour\":\"proxy\",\"update_interval\":\"1d\"}"
  done
}

add_all_rule_sets() {
  if [ -z "$GEOSITE_BYPASS" ] && [ -z "$GEOIP_BYPASS" ]; then
    return
  fi

  echo "[start.sh] sing-box add route rules"

  local tmpfile
  tmpfile=$(mktemp 2>/dev/null)

  local first_rule=true

  {
    echo '{"dns":{"rules":['

    [ -n "$GEOSITE_BYPASS" ] && gen_rules dns geosite "$GEOSITE_BYPASS" first_rule
    [ -n "$GEOIP_BYPASS" ] && gen_rules dns geoip "$GEOIP_BYPASS" first_rule

    echo ']},'

    # shellcheck disable=SC2034
    first_rule=true

    echo '"route":{"rules":['

    [ -n "$GEOSITE_BYPASS" ] && gen_rules route geosite "$GEOSITE_BYPASS" first_rule
    [ -n "$GEOIP_BYPASS" ] && gen_rules route geoip "$GEOIP_BYPASS" first_rule

    echo '],"rule_set":['

    # shellcheck disable=SC2034
    first_rule=true

    [ -n "$GEOSITE_BYPASS" ] && gen_rule_sets geosite "$GEOSITE_BYPASS" first_rule
    [ -n "$GEOIP_BYPASS" ] && gen_rule_sets geoip "$GEOIP_BYPASS" first_rule

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