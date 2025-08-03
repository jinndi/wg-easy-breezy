<p align="center">
<img alt="wg-easy-breezy" src="/logo.webp">
</p>

<p align="center">
<img alt="Release" src="https://img.shields.io/github/v/release/jinndi/wg-easy-breezy">
<img alt="Commits since latest release" src="https://img.shields.io/github/commits-since/jinndi/wg-easy-breezy/latest">
<img alt="Code size in bytes" src="https://img.shields.io/github/languages/code-size/jinndi/wg-easy-breezy">
<img alt="License" src="https://img.shields.io/github/license/jinndi/wg-easy-breezy">
<img alt="Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/jinndi/wg-easy-breezy/docker-publish.yml">
</p>

<p align="center">
Развёртывание и управление контейнерами wg-easy с использованием Podman, включая маршрутизацию трафика через прокси Shadowsocks и настройку веб-сервера Caddy в роли реверс-прокси с автоматическим продлением SSL-сертификатов
</p>

<p align="center">
  <a href="/README.md"><img alt="English" src="https://img.shields.io/badge/English-d9d9d9"></a>
  <a href="/README-ru.md"><img alt="Русский" src="https://img.shields.io/badge/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-d9d9d9"></a>
</p>

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
curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/proxy-ss/wg-easy-breezy && bash wg-easy-breezy
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
  curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/proxy-ss/ss-easy-breezy && bash ss-easy-breezy
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
5. [Дешевые и качественные VPS (just.hosting)](https://just.hosting/?ref=231025)
6. [Лучший регистратор доменов (namecheap.com)](https://www.namecheap.com)
7. [Бесплатные субдомены (duckdns.org)](https://www.duckdns.org)

