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
Deployment and management of wg-easy containers using Podman, including traffic routing through a Shadowsocks proxy and configuration of the Caddy web server as a reverse proxy with automatic SSL certificate renewal.
</p>

<p align="center">
  <a href="/README.md"><img alt="English" src="https://img.shields.io/badge/English-d9d9d9"></a>
  <a href="/README-ru.md"><img alt="Русский" src="https://img.shields.io/badge/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-d9d9d9"></a>
</p>

## Features:

- 💥 Selecting the installation mode for wg-easy: either standard or via a Shadowsocks proxy to another server using tun2socks.

- 🧦 Creating a Shadowsocks server (Rust implementation) using the `ss-easy-breezy` script and obtaining a link to specify in the `wg-easy-breezy` script.

- 📦 Adding and removing wg-easy containers via the script menu, with all necessary settings applied automatically.

- 🌐 Adding, modifying, and deleting a domain name (requires setting an A record in your domain registrar's panel pointing to your server's IP address).

- 🚀 Automatic deployment of the Caddy web server as a reverse proxy with auto-renewing SSL certificate.

- 🔑 Changing the password for the wg-easy web interface(s).

- ⚡️ Optimized network settings on both the server host and within the containers.

## Requirements:

1. A VPS server with at least 1 GB of RAM, running Linux (Ubuntu 24.04+ or Debian 12+), with an IPv4 address and a kernel version ≥ 6. (You’ll need two servers if you want to deploy the Shadowsocks server separately.)
2. Access and execution via SSH as the root user.

## Installation:

From under ssh, install the main script `wg-easy-breezy`

```
curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/wg-easy-breezy && bash wg-easy-breezy
```

Follow the on-screen instructions. You will be prompted to enter the following:

- **Choosing a language**  
  Choose one of the following:
  - English
  - Russian

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
  
  You can obtain it by installing `ss-easy-breezy` on another server commander:

  ```
  curl -fsSLO -H "Cache-Control: no-cache" -H "Pragma: no-cache" https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/ss-easy-breezy && bash ss-easy-breezy
  ```
  Installation directory: `/opt/shasowsocks-rust/`
  
  The installed server is managed using the `sseb` command

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
5. [Cheap and high-quality VPS (just.hosting)](https://just.hosting/?ref=231025 )
6. [The Best Domain Registrar (namecheap.com)](https://www.namecheap.com)
7. [Free subdomains (duckdns.org)](https://www.duckdns.org)