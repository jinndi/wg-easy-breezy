# WG-EASY-BREEZY

![RU](https://github.com/jinndi/wg-easy-breezy/blob/main/README.md) | ![EN](https://github.com/jinndi/wg-easy-breezy/blob/main/README-en.md)

### Развертывание wg-easy / wg-easy через tun2socks прокси shasowsocks / caddy реверс прокси


![Схема работы](https://github.com/user-attachments/assets/f041ac27-b01c-45e1-87c5-58f05bb432c3)


## Особенности:

Выбор режима установки wg-easy: обычный либо через прокси shasowsocks к другому серверу по средством tun2socks

Cоздание shasowsocks сервера (rust порт) через скрипт `ss-easy-breezy` и получние ссылки для ее указания в `wg-easy-breezy` скрипте

Добавление, удаление контейнеров wg-easy из меню скрипта со всеми необходимыми настройками

Добавление, изменение, удаление доменного имени (необходима настройка `A` записи в панели регистратора на IP вашего сервера)

Автоматическое развертываение Caddy веб сервера как реверс прокси с автопродляемым SSL сертификатом

Смена пароля от веб интерфейса(ов) wg-easy

Оптимизированные сетевые настройки как на хосте сервера так и внутри контейнеров 

## Требования:

1. VPS сервер от 1GB RAM c ОС Linux Ubuntu 24.04+ либо Debian 12+, IPv4 адрес, ядро версии >=6 (2 шт если на другом хотите развернуть shasowsocks сервер)
2. Работа и запуск по ssh от root пользователя

## Установка:

### ss-easy-breezy

Если есть 2 VPS сервера, допустим один `в вашей резиденции (сервер A)`, другой для обхода блокировок `за границей (сервер B)`, 
то для начала установите на "B" shasowsocks сервер из ssh коммандой:

```
curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/ss-easy-breezy && bash ss-easy-breezy
```
В процессе установки вам нужно будет ввести только номер порта, после завершения вы получите ссылку для подлючения, сохраните её.

Директория установки: `/opt/shasowsocks-rust/`

Управление установленным сервером осуществляется по комманде `sseb`

### wg-easy-breezy

На сервере "A" из под ssh выполните установку основного скрипта `wg-easy-breezy`

```
curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/wg-easy-breezy && bash wg-easy-breezy
```

Cледовать инстукциям на экране. Будут запросы на ввод данных:

 1. `режим установки` - выберите из обычного и прокси shasowsocks
 2. `тег сервиса` - для постфиксов названий сервисов, контейнеров и ссылок для входа в веб интерфейсы
 1. `имя домена` - впишите если он есть и хотите обезопасить использование веб интерфейса(ов), можно настроить позже из меню
 2. `e-mail адрес` - если указали имя домена (для получения SSL сертификата Caddy сервером)
 3. `ссылка shasowsocks` - если выбрали прокси режим установки, получите её установкой `ss-easy-breezy` на другом сервере
 4. `порт Wireguard` - можете вписать любой из указанного диапазона (для веб интерфейса(ов) будет на еденицу больше)
 5. `диапазон адресов клиентов Wireguard` - в формате wg-easy - 10.0.0.x, 10.1.0.x, и т.п.
 6. `пароль для входа в веб-интерфейс(ы)` - будет автоматически закодирован и записан в .env файл

После завершения установки вы получите ссылку на веб интерфейс

Директория установки: `/opt/wg-easy-breezy/`

Управление установленным сервером осуществляется по комманде `wgeb`



## Ссылки:
1. [Github wg-easy](https://github.com/wg-easy/wg-easy)
2. [Github shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)
3. [Github tun2socks](https://github.com/xjasonlyu/tun2socks)
4. [Github caddy](https://github.com/caddyserver/caddy)
5. [Дешевые и качественные VPS](https://just.hosting/?ref=231025)
6. [Лучший регистратор доменов](https://www.namecheap.com)
