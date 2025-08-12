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
PATH_EXCLUDE_DOMAINS_BYPASS="/app/exclude_bypass.domains"

LOG_LEVEL="${LOG_LEVEL:-warn}"

DNS_PROXY="${DNS_PROXY:-1.1.1.1}"
DNS_DIRECT="${DNS_DIRECT:-77.88.8.8}"

## Rules for bypassing proxies
# GEOSITE https://github.com/SagerNet/sing-geosite/tree/rule-set
# Example: category-ru,geolocation-cn,speedtest
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

gen_rule_sets() {
  local rules="$1"
  local first_rule=true

  IFS=',' read -ra entries <<< "$rules"
  for rule in "${entries[@]}"; do
    [ "$first_rule" = true ] && first_rule=false || echo ","
    local base_url="https://raw.githubusercontent.com/SagerNet/sing-${rule%%-*}/rule-set/${rule}.srs"
    echo "{\"tag\":\"${rule}\",\"type\":\"remote\",\"format\":\"binary\",\"url\":\"${base_url}\",
        \"download_detour\":\"proxy\",\"update_interval\":\"1d\"}"
  done
}

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
        "rule_set": "geosite-category-ads-all",
        "action": "reject"
      }
    ],
    "final": "dns-proxy",
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
      "tag": "direct",
      "type": "direct",
      "domain_resolver": "dns-direct",
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
      $(gen_rule_sets "geosite-category-ads-all")
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

add_all_rule_sets() {
  if [ -z "$GEOSITE_BYPASS" ] && [ -z "$GEOIP_BYPASS" ]; then
    return
  fi

  echo "[start.sh] sing-box add route rules"

  local tmpfile
  tmpfile=$(mktemp 2>/dev/null)

  local EXCLUDE_DOMAINS_BYPASS GEO_BYPASS_LIST GEO_BYPASS_FORMAT

  [ -f "$PATH_EXCLUDE_DOMAINS_BYPASS" ] && \
  EXCLUDE_DOMAINS_BYPASS=$(grep -v '^[[:space:]]*$' "$PATH_EXCLUDE_DOMAINS_BYPASS" | paste -sd,) && \
  [ -n "$EXCLUDE_DOMAINS_BYPASS" ] && EXCLUDE_DOMAINS_BYPASS="\"${EXCLUDE_DOMAINS_BYPASS//,/\",\"}\"" 

  [ -n "$GEOSITE_BYPASS" ] && GEOSITE_BYPASS="${GEOSITE_BYPASS//,/\,geosite-},"
  [ -n "$GEOIP_BYPASS" ] && GEOIP_BYPASS="${GEOIP_BYPASS//,/\,geoip-}"
  GEO_BYPASS_LIST="${GEOSITE_BYPASS}${GEOIP_BYPASS}"
  GEO_BYPASS_FORMAT="\"${GEO_BYPASS_LIST//,/\",\"}\""

  {
    echo "{\"dns\":{\"rules\":[{\"rule_set\":\[${GEO_BYPASS_FORMAT}],\"server\":\"dns-direct\"}]},"
    echo '"route":{"rules":['
    [ -n "$EXCLUDE_DOMAINS_BYPASS" ] && echo "{\"domain_keyword\":[${EXCLUDE_DOMAINS_BYPASS}],\"outbound\": \"proxy\"},"
    echo "{\"rule_set\":\[${GEO_BYPASS_FORMAT}],\"outbound\":\"direct\"}],"
    echo "\"rule_set\":['$(gen_rule_sets "$GEO_BYPASS_LIST")]}}"
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