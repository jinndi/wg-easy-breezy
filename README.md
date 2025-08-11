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
Deployment and management of wg-easy containers using Podman, including traffic routing through an XRay VLESS proxy with XTLS-Reality, and configuration of the Caddy web server as a reverse proxy with automatic SSL certificate renewal.
</p>

<p align="center">
  <a href="/README.md"><img alt="English" src="https://img.shields.io/badge/English-d9d9d9"></a>
  <a href="/README-ru.md"><img alt="Русский" src="https://img.shields.io/badge/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-d9d9d9"></a>
</p>

## Features:

- 💥 Selection of the wg-easy installation mode: standard, or via a proxy to the XRay server using sing-box.

- ⚡️ Create an XRay server with VLESS XTLS-Reality using the `xray-easy-breezy` script and get the encoded config string to point to in the `wg-easy-breezy` script.

- 📦 Adding and removing wg-easy containers via the script menu, with all necessary settings applied automatically.

- 🌐 Adding, modifying, and deleting a domain name (requires setting an A record in your domain registrar's panel pointing to your server's IP address).

- 💻 Automatic deployment of the Caddy web server as a reverse proxy with auto-renewing SSL certificate.

- 🔑 Changing the password for the wg-easy web interface(s), proxy manager for previously created services.

- 🚀 Optimized network settings on both the server host and within the containers.

## Requirements:

1. A VPS server with minimal specifications: at least 1 GB of RAM, running Linux Ubuntu 24.04+ or Debian 12+ OS, with an IPv4 address and kernel version 6+. (Two servers are required if you need XRay for proxying with a free port 443 on it)
2. Operation and startup via SSH as the root user.

## Installation:

From under ssh, install the main script `wg-easy-breezy`

```
curl -fsSLO "https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/wg-easy-breezy?t=$(date +%s)" && bash wg-easy-breezy
```

Follow the on-screen instructions. You will be prompted to enter the following:

- **Choosing a language**  
  Choose one of the following:
  - English
  - Russian

- **Installation mode**  
  Choose one of the following:
  - Standard wg-easy
  - Proxy wg-easy (VLESS-TCP-XTLS-Vision-REALITY)

- **Service tag**  
  Used as a postfix in service names, container names, and web interface URLs.

- **Domain name**  
  Optional — used to secure access to the web interface via HTTPS.  
  *(Can be set later through the menu.)*

- **Email address**  
  Required if a domain name is provided — used by the Caddy server to obtain an SSL certificate.

- **XRay encoded string** 
  Required if proxy mode is selected.  
  
  You can obtain it by installing `xray-easy-breezy` on another server commander:

  ```
  curl -fsSLO "https://raw.githubusercontent.com/jinndi/wg-easy-breezy/main/xray-easy-breezy?t=$(date +%s)" && bash xray-easy-breezy
  ```
  Installation directory: `/opt/xrayeb/`
  
  The installed server is managed using the `xrayeb` command

- **WireGuard port**  
  Choose any port from the suggested range.  
  *(The web interface will use the next port number.)*

- **WireGuard client address range**  
  In the format used by `wg-easy`, e.g.:  
  `10.0.0.x`, `10.1.0.x`, etc.

- **Web interface password**  
  Will be automatically encoded and saved to the `.env` file.

After the installation is complete, you will receive a link to the web interface.

Installation directory: `/opt/wgeb/`

The installed server is managed using the `wgeb` command



## Links:
1. [Github wg-easy](https://github.com/wg-easy/wg-easy)
2. [Github XRay](https://github.com/XTLS/Xray-core)
3. [Github sing-box](https://github.com/SagerNet/sing-box)
4. [Github caddy](https://github.com/caddyserver/caddy)
5. [Cheap and high-quality VPS (just.hosting)](https://just.hosting/?ref=231025 )
6. [The Best Domain Registrar (namecheap.com)](https://www.namecheap.com)
7. [Free subdomains (duckdns.org)](https://www.duckdns.org)