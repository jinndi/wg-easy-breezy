# WG-EASY-BREEZY

![RU](https://github.com/jinndi/wg-easy-breezy/blob/main/README.md) | ![EN](https://github.com/jinndi/wg-easy-breezy/blob/main/README-en.md)

### Deployment of WG-easy / WG-easy via tun2socks proxy shasowsocks / caddy reverse proxy


![The scheme of work](https://github.com/user-attachments/assets/f041ac27-b01c-45e1-87c5-58f05bb432c3 )


## Features:

Selecting the installation mode for wg-easy: either standard or via a Shadowsocks proxy to another server using tun2socks.

Creating a Shadowsocks server (Rust implementation) using the `ss-easy-breezy` script and obtaining a link to specify in the `wg-easy-breezy` script.

Adding and removing wg-easy containers via the script menu, with all necessary settings applied automatically.

Adding, modifying, and deleting a domain name (requires setting an A record in your domain registrar's panel pointing to your server's IP address).

Automatic deployment of the Caddy web server as a reverse proxy with auto-renewing SSL certificate.

Changing the password for the wg-easy web interface(s).

Optimized network settings on both the server host and within the containers.

## Requirements:

1. A VPS server with at least 1 GB of RAM, running Linux (Ubuntu 24.04+ or Debian 12+), with an IPv4 address and a kernel version ≥ 6. (You’ll need two servers if you want to deploy the Shadowsocks server separately.)
2. Access and execution via SSH as the root user.

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

Follow the on-screen instructions. You will be prompted to enter the following:

- **Installation mode**  
  Choose one of the following:
  - Standard
  - Proxy via Shadowsocks

- **Service tag**  
  Used as a postfix in service names, container names, and web interface URLs.

- **Domain name**  
  Optional — used to secure access to the web interface via HTTPS.  
  *(Can be set later through the menu.)*

- **Email address**  
  Required if a domain name is provided — used by the Caddy server to obtain an SSL certificate.

- **Shadowsocks link**  
  Required if proxy mode is selected.  
  You can obtain it by installing `ss-easy-breezy` on another server.

- **WireGuard port**  
  Choose any port from the suggested range.  
  *(The web interface will use the next port number.)*

- **WireGuard client address range**  
  In the format used by `wg-easy`, e.g.:  
  `10.0.0.x`, `10.1.0.x`, etc.

- **Web interface password**  
  Will be automatically encoded and saved to the `.env` file.

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
