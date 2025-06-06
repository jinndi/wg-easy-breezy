# WG-EASY-BREEZY

### bash-cкрипт развертывания wg-easy + wg-easy через tun2socks прокси shasowsocks + caddy реверс прокси


![Схема работы](https://github.com/user-attachments/assets/f041ac27-b01c-45e1-87c5-58f05bb432c3)


## Возможности:

Два WireGuard-а с интерфейсом wg-easy на одном хосте, второй опционален и настраивается на работу через прокси shasowsocks к другому серверу.

Опционально: Быстрое создание shasowsocks сервера через скрипт `ss-easy-breezy` и получние ссылки для ее указания в `wg-easy-breezy` скрипте (если нужно развернуть второй wg через прокси)

Опционально: Автонастройка Caddy веб сервера как реверс прокси с автопродляемым SSL сертификатом (необходимо купленное настроенное доменное имя с `A` записью на ip вашего сервера)

## Требования:

1. VPS сервер от 1GB RAM c ОС Linux Ubuntu 20.04+ либо Debian 11+ (2 шт если на другом хотите развернуть shasowsocks сервер)
2. Права root пользователя

## Установка:

### ss-easy-breezy

Если есть 2 VPS сервера, допустим один `в вашей резиденции (сервер A)`, другой для обхода блокировок `за границей (сервер B)`, 
то для начала установите на "B" shasowsocks сервер из ssh коммандой:

```
curl -fsSLO https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/ss-easy-breezy?nc=$(date +%s) && bash ss-easy-breezy
```
В процессе установки вам нужно будет ввести только номер порта, после завершения вы получите ссылку для подлючения, сохраните её.

Управление установленным сервером осуществляется по комманде ``sseb``

### wg-easy-breezy

На сервере "A" из под ssh выполните установку основного скрипта `wg-easy-breezy`

```
curl -fsSLO https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/wg-easy-breezy?nc=$(date +%s) && bash wg-easy-breezy
```

Cледовать инстукциям на экране. Будут запросы на ввод данных:

 1. `имя домена` - впишите если он есть и хотите обезопасить вход в веб интерфейсы
 2. `ваш e-mail адрес` - если домен указали (нужно что-бы получить SSL сертификат)
 3. `ссылка для подключения к shasowsocks` (если получали ее установкой `ss-easy-breezy`)
 4. `порт(ы) Wireguard` (для веб интерфейса(ов) будут на еденицу больше)
 5. `диапазон(ы) адресов клиентов Wireguard` Wireguard (можно просто нажать Enter)
 6. `пароль для входа в веб-интерфейс(ы)`

Управление установленным сервером осуществляется по комманде ``wgeb``



## Ссылки:
1. [Github wg-easy](https://github.com/wg-easy/wg-easy)
2. [Github shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)
3. [Github tun2socks](https://github.com/xjasonlyu/tun2socks)
4. [Github caddy](https://github.com/caddyserver/caddy)
5. [Дешевые и качественные VPS](https://just.hosting/?ref=231025)
6. [Лучший регистратор доменов](https://www.namecheap.com)
