# WG-EASY-BREEZY


![RU](https://github.com/jinndi/wg-easy-breezy/blob/main/README.md) | ![EN](https://github.com/jinndi/wg-easy-breezy/blob/main/README-en.md)

### Deploying wg-easy + wg-easy via tun2socks proxy shasowsocks + caddy reverse proxy

![Scheme of work](https://github.com/user-attachments/assets/f041ac27-b01c-45e1-87c5-58f05bb432c3)

## Features:

Two WireGuards with wg-easy interface on one host, the second is optional and is configured to work through a shasowsocks proxy to another server.

Optional: Quick creation of a shasowsocks server via the `ss-easy-breezy` script and getting a link to specify it in the `wg-easy-breezy` script (if you need to deploy a second wg through a proxy)

Optional: Automatic configuration of the Caddy web server as a reverse proxy with an auto-renewable SSL certificate (you need a purchased configured domain name with an `A` record on your server's IP)

## Requirements:

1. VPS server from 1GB RAM with OS Linux Ubuntu 24.04+ or Debian 12+, kernel version >=6 (2 pcs if you want to deploy shasowsocks server on another)
2. Root user rights

## Installation:

### ss-easy-breezy

If you have 2 VPS servers, say one `at your residence (server A)`, the other to bypass blocking `abroad (server B)`, then first install the shasowsocks server on "B" from ssh command:

```
curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/ss-easy-breezy && bash ss-easy-breezy
```
During the installation you will only need to enter the port number, after completion you will receive a link for connection, save it.

Installation directory: `/opt/shasowsocks-rust`

The installed server is managed by the command `sseb`

### wg-easy-breezy

On server "A" from under ssh, install the main script `wg-easy-breezy`

```
curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/wg-easy-breezy && bash wg-easy-breezy
```

Follow the instructions on the screen. You will be prompted to enter data:

1. `domain name` - enter if you have one and want to secure the use of the web interface(s)
2. `your e-mail address` - if you specified a domain (to obtain an SSL certificate)
3. `link to connect to shasowsocks` (you will receive it after installing `ss-easy-breezy`)
4. `Wireguard port(s)` (for the web interface(s) they will be one more)
5. `Wireguard client address range(s)` Wireguard (you can simply press Enter)
6. `password to log in to the web interface(s)`

After installation is complete, you will receive a link(s) to the web interface(s)

Installation directory: `/opt/wg-easy-breezy`

The installed server is managed using the `wgeb` command

## Links:
1. [Github wg-easy](https://github.com/wg-easy/wg-easy)
2. [Github shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)
3. [Github tun2socks](https://github.com/xjasonlyu/tun2socks)
4. [Github caddy](https://github.com/caddyserver/caddy)
5. [Cheap and quality VPS](https://just.hosting/?ref=231025)
6. [Best domain registrar](https://www.namecheap.com)
