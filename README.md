# ⚡ JTG Panel V2 - Advanced Installer Core

> **Credits:** Original Panel by **Jishnu** | Script Core & Optimization by **MrZetrix**

---

## 🌟 Overview

**JTG Panel V2** is an ultra-optimized command-line interface and deployment manager designed to automate the full setup, repair, and tunneling of your JTP web panel. Optimized specifically for **Ubuntu, Debian, and Docker** environments.

---

## ✨ Features

* **⚡ 1-Click Installer:** Clones the repository, configures dependencies, builds assets, and boots the entire panel in seconds.
* **☁️ 1-Click Cloudflare Setup:** Downloads architecture-matched `cloudflared` binaries and bridges your custom domain using Zero-Trust Tunnels.
* **🛠️ 1-Click Problem Repair:** Wipes corrupted `dpkg`/`apt` locks, clears broken NPM caches, and automatically rebuilds missing modules.
* **🔌 1-Click Power Controls:** Effortlessly **Start**, **Stop**, or **Restart** the JTG Panel daemon on demand with 100% accurate Node-based PM2 status tracking.

---

## ⚙️ System Requirements

* **Operating System:** Ubuntu (20.04/22.04/24.04), Debian (11/12), or Docker containers.
* **Privileges:** `root` access or a user with `sudo` permissions.
* **Dependencies:** Internet connection to fetch dependencies.

---

## 🚀 How To Install & Setup

### **Phase 1: Launch the Installer**

Run the following command in your terminal to launch the interactive UI:

```bash
bash <(curl -sSL [https://raw.githubusercontent.com/mrzetrixyt-525/JTG-Panel-installer/refs/heads/main/installer.sh](https://raw.githubusercontent.com/mrzetrixyt-525/JTG-Panel-installer/refs/heads/main/installer.sh))
