# Metasploit Framework Manager

![metasploit](https://img.shields.io/badge/metasploit-installer-blue.svg)
![platform](https://img.shields.io/badge/platform-linux--only-red.svg)

A minimal, clean, and modular Bash script to **install** or **upgrade** the Metasploit Framework from source on Debian-based Linux systems.  
Tested for **lab environments, CTFs, and Red Team training labs** where package managers are restricted or OPSEC matters.

---

## 🚀 Features

- One-liner **install** or **upgrade** workflow.
- Pulls directly from Rapid7's official Metasploit GitHub repo.
- Installs dependencies and configures PostgreSQL.
- Uses local Ruby environment to avoid permission issues.
- Creates system-wide symlinks: `msfconsole`, `msfvenom`.
- Supports stealth-conscious workflows (no auto-telemetry or background syncs).

---

## 🛠️ Requirements

- **Linux only** (tested on Ubuntu 20.04+ / Debian).
- `sudo` privileges required.
- Ruby, Bundler, Git, and PostgreSQL are handled by the script.
- Script must be run from a terminal with internet access.


## 🧪 Usage
Permissions
```bash
chmod +x msf_manager.sh
```

Runing it 
```bash
./msf_manager.sh --install
```

Launching msfconsole after install:
```bash 
msfconsole
```

To upgrade an existing clone:
```bash 
./msf_manager.sh --upgrade
```

## 🧼 Cleanup / Uninstall
To remove Metasploit completely:
```bash 
sudo rm -rf /opt/metasploit-framework
sudo rm /usr/local/bin/msfconsole /usr/local/bin/msfvenom
```

## 👤 Author Notes

This script was created out of necessity:  
Installing Metasploit via traditional package managers (e.g., `apt install metasploit-framework`) now enforces a **browser-based registration step** — an issue in many **CTF**, **cloud**, and **headless lab environments** where GUI/browser access isn't available or desired.

By installing directly from the official GitHub source with Bundler, this script:

- Skips the browser registration entirely.
- Avoids telemetry prompts.
- Ensures full transparency and customizability of your MSF setup.
- Is ideal for **offline boxes**, **stealth-focused deployments**, and **lab automation pipelines**.

You can modify the script to route through Tor or proxies (e.g., `torsocks`, `proxychains`) if your environment demands stealth.
