# WG-EASY-BREEZY

![RU](https://github.com/jinndi/wg-easy-breezy/blob/main/README.md) | ![EN](https://github.com/jinndi/wg-easy-breezy/blob/main/README-en.md)

### Deployment of WG-easy / WG-easy via tun2socks proxy shasowsocks / caddy reverse proxy


![The scheme of work](https://github.com/user-attachments/assets/f041ac27-b01c-45e1-87c5-58f05bb432c3 )


## Features:

Selecting the installation mode of wg-easy: either the usual one or through the shasowsocks proxy to another server using tun2socks

Creating a shasowsocks server (rust port) using the `ss-easy-breezy` script and getting links to specify it in the `wg-easy-breezy` script

Adding and removing wg-easy containers from the script menu with all necessary settings

Adding, changing, deleting a domain name (it is necessary to configure the `A` entry in the registrar panel for your server's IP)

Automatic deployment of the Caddy web server as a reverse proxy with an auto-renewing SSL certificate

Changing the password from the wg-easy web interface(s)

Optimized network settings both on the server host and inside containers 

## Requirements:

1. VPS server from 1GB RAM with Linux OS Ubuntu 24.04+ or Debian 12+, IPv4 address, kernel version >=6 (2 pcs if you want to deploy a shasowsocks server on another one)
2. Operation and launch via ssh from the root user

## Installation:

### ss-easy-breezy

If there are 2 VPS servers, let's say one is `in your residence (server A)`, the other is for bypassing locks `abroad (server B)`,
then first install the ssh command server on "B" shasowsocks:

```
curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/ss-easy-breezy && bash ss-easy-breezy
```
During the installation process, you will only need to enter the port number. After completion, you will receive a link to connect and save it.

Installation directory: `/opt/shasowsocks-rust/`

The installed server is managed using the `sseb` command

### wg-easy-breezy

On the server "A" from under ssh, install the main script `wg-easy-breezy`

```
curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/wg-easy-breezy && bash wg-easy-breezy
```

Follow the instructions on the screen. There will be requests for data entry:

 1. `Installation mode` - select from the regular and proxy shasowsocks
 2. `service tag` - for postfixes of names of services, containers, and links for logging into web interfaces
 3. `domain name` - enter if you have one and want to secure the use of the web interface(s), you can configure it later from the menu
 4. `e-mail address` - if you have specified the domain name (for obtaining an SSL certificate by the Caddy server)
 5. `shasowsocks link` - if you have selected the proxy installation mode, get it by installing `ss-easy-breezy` on another server
 6. `Wireguard port` - you can enter any of the specified range (for the web interface(s) it will be one more)
 7. `Wireguard client address range` - in the format wg-easy - 10.0.0.x, 10.1.0.x, etc.
 8. `password for logging into the web interface(s)` - will be automatically encoded and written to an .env file

After the installation is complete, you will receive a link to the web interface.

Installation directory: `/opt/wg-easy-breezy/`

The installed server is managed using the `wgeb` command



## Links:
1. [Github wg-easy](https://github.com/wg-easy/wg-easy)
2. [Github shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)
3. [Github tun2socks](https://github.com/xjasonlyu/tun2socks)
4. [Github caddy](https://github.com/caddyserver/caddy)
5. [Cheap and high-quality VPS](https://just.hosting/?ref=231025 )
6. [The Best Domain Registrar](https://www.namecheap.com )
