#!/bin/bash

set -e

# Загрузка модулей tcp_congestion_control
for module in tcp_hybla tcp_bbr; do
  if modprobe -q "$module"; then
    echo "[entrypoint.sh] Модуль $module загружен"
  else
    echo "[entrypoint.sh] Ошибка загрузки модуля $module"
  fi
done

# Применяем сетевые настройки из /etc/sysctl.conf
/sbin/sysctl -p > /dev/null 2>&1

# Если SS_LINK (Ссылка SIP002 URI scheme для полкючение к серверу shadowsocks) не пуста
if [ -n "$SS_LINK" ]; then

  # Добавляем префикс ss://, если его нет
  [[ "$SS_LINK" != ss://* ]] && SS_LINK="ss://${SS_LINK}"
  # Удаляем префикс ss:// для извлечения данных
  ss_clean_link="${SS_LINK#ss://}"
  # Удаляем всё после # (коммент ссылки если есть)
  ss_clean_link="${ss_clean_link%%#*}"

  # Извлечение адреса сервера (IP:ПОРТ)
  SS_SERVER_ADDR="${ss_clean_link#*@}"

  # Извлечение IP сервера
  SS_IP="${SS_SERVER_ADDR%%:*}"

  # Извлекаем base64 кодированную строку
  base64_part="${ss_clean_link%@*}"
  # Декодирование base64 строки
  decoded=$(echo "$base64_part" | base64 --decode 2>/dev/null) || {
    echo "[entrypoint.sh] Ошибка: base64 не удалось декодировать ссылку SS_LINK"
    exit 1
  }
  
  # Получаем метод шифра 
  SS_ENCRYPT_METHOD="${decoded%%:*}"

  # Получаем пароль
  SS_PASSWORD="${decoded#*:}"; SS_PASSWORD="${SS_PASSWORD%@*}"

  # Название для прокси интерфейса shadowsocks
  SS_TUN_NAME="${SS_TUN_NAME:-tun0}"

  # Получение имени интерфейса по умолчанию
  DIF=$(ip route | awk '/default/ {print $5}' | head -n1)

  # Получение локального IP адреса на интерфейсе
  LIP=$(ip -4 addr show "$DIF" | awk '/inet / {print $2}' | cut -d/ -f1)

  # Получение основного шлюза
  MIP=$(ip route | awk '/default via/ {print $3}' | head -n1)

  # Настройка и поднятие TUN интерфейса
  echo "[entrypoint.sh] Настраиваем $SS_TUN_NAME интерфейс..."
  ip tuntap add mode tun dev "$SS_TUN_NAME" || true 
  ip addr add 192.168.0.33/24 dev "$SS_TUN_NAME"
  ip link set dev "$SS_TUN_NAME"
  ip link set dev "$SS_TUN_NAME" up

  # Настройка маршрутов
  echo "[entrypoint.sh] Настраиваем ip routing...."
  ip route del default dev "$DIF"
  ip route add default via "$MIP" dev "$DIF" metric 200
  ip rule add from "$LIP" table lip
  ip route add default via "$MIP" dev "$DIF" table lip
  ip route add "$SS_IP/32" via "$MIP" dev "$DIF"
  ip route add default dev "$SS_TUN_NAME" metric 50 

  echo "[entrypoint.sh] Запускаем sslocal proxy к $SS_IP..."
  nohup /app/sslocal --protocol tun -U --server-addr "$SS_SERVER_ADDR" \
    --encrypt-method "$SS_ENCRYPT_METHOD" --password "$SS_PASSWORD" \
    --outbound-bind-interface $DIF --tun-interface-name "$SS_TUN_NAME" \
    --tcp-keep-alive 25 --timeout 300 --udp-timeout 300 \
    --udp-max-associations 512 --nofile 51200 --tcp-fast-open \
    > /app/sslocal.log 2>&1 &

  # Пример через tun2socks
  #echo "[entrypoint.sh] Запускаем tun2socks proxy к $SS_IP..."
  #nohup /app/tun2socks -interface "$DIF" -device "tun://$SS_TUN_NAME" \
  #  -proxy "$SS_LINK" > /app/tun2socks.log 2>&1 &
fi

# Запуск сервера wg-easy
echo "[entrypoint.sh] Запускаем WEB UI сервер wg-easy..."
exec /usr/bin/dumb-init node /app/server.js