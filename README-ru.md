# WG-EASY-BREEZY
![GitHub Release](https://img.shields.io/github/v/release/jinndi/wg-easy-breezy)
![GitHub commits since latest release](https://img.shields.io/github/commits-since/jinndi/wg-easy-breezy/latest)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/jinndi/wg-easy-breezy)
![GitHub License](https://img.shields.io/github/license/jinndi/wg-easy-breezy)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/jinndi/wg-easy-breezy/docker-publish.yml)

Развёртывание и управление контейнерами wg-easy с использованием Podman, включая маршрутизацию трафика через прокси Shadowsocks и настройку веб-сервера Caddy в роли реверс-прокси с автоматическим продлением SSL-сертификатов

![EN](https://github.com/jinndi/wg-easy-breezy/blob/main/README.md)

## Особенности:

- 💥 Выбор режима установки wg-easy: обычный или через прокси Shadowsocks к другому серверу с использованием tun2socks.

- 🧦 Создание сервера Shadowsocks (реализация на Rust) с помощью скрипта `ss-easy-breezy` и получение ссылки для указания в скрипте `wg-easy-breezy`.

- 📦 Добавление и удаление контейнеров wg-easy из меню скрипта с автоматическим применением всех необходимых настроек.

- 🌐 Добавление, изменение и удаление доменного имени (требуется предварительная настройка A-записи в панели регистратора на IP-адрес вашего сервера).

- 🚀 Автоматическое развертывание веб-сервера Caddy как реверс-прокси с автопродлеваемым SSL-сертификатом.

- 🔑 Смена пароля от веб-интерфейса(ов) wg-easy.

- ⚡️ Оптимизированные сетевые настройки как на хосте сервера, так и внутри контейнеров.

## Требования:

1. VPS-сервер с минимальными характеристиками: от 1 ГБ оперативной памяти, с установленной ОС Linux Ubuntu 24.04+ или Debian 12+, с IPv4-адресом и ядром версии 6 или выше. (Понадобится два сервера, если вы хотите развернуть Shadowsocks отдельно на другом сервере.)
2. Работа и запуск через SSH от имени пользователя root.

## Установка:

Из под ssh выполните установку основного скрипта `wg-easy-breezy`

```
curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/wg-easy-breezy && bash wg-easy-breezy
```

Следуйте инструкциям на экране. В процессе будут запрашиваться следующие данные:

- **Выбор языка**  
  Выберите один из двух вариантов:
  - Английский
  - Русский

- **Режим установки**  
  Выберите один из двух вариантов:
  - Обычный
  - Через прокси (Shadowsocks)

- **Тег сервиса**  
  Используется как постфикс в названиях сервисов, контейнеров и ссылках для входа в веб-интерфейсы.

- **Имя домена**  
  Укажите, если хотите защитить доступ к веб-интерфейсу(ам) через HTTPS.  
  *(Можно указать позже через меню.)*

- **E-mail адрес**  
  Требуется при наличии доменного имени — используется Caddy-сервером для получения SSL-сертификата.

- **Ссылка на Shadowsocks**  
  Указывается, если выбран прокси-режим. 
  
  Получить её можно, установив `ss-easy-breezy` на другом сервере коммандой:

  ```
  curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/ss-easy-breezy && bash ss-easy-breezy
  ```
  Директория установки: `/opt/shasowsocks-rust/`
  
  Управление установленным сервером осуществляется по комманде `sseb`

- **Порт WireGuard**  
  Выберите любой порт из предложенного диапазона.  
  *(Порт для веб-интерфейса будет на единицу больше.)*

- **Диапазон адресов клиентов WireGuard**  
  В формате, поддерживаемом `wg-easy`, например:  
  `10.0.0.x`, `10.1.0.x`, и т.п.

- **Пароль для входа в веб-интерфейс(ы)**  
  Будет автоматически закодирован и записан в `.env` файл.

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
