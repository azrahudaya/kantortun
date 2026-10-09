# kantortun

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4.0+-4EAA25?style=flat&logo=gnubash&logoColor=white)
![systemd](https://img.shields.io/badge/systemd-user_service-555555?style=flat&logo=systemd&logoColor=white)
![SSH](https://img.shields.io/badge/SSH-OpenSSH-231F20?style=flat)
![GNOME](https://img.shields.io/badge/GNOME-AppIndicator-4a86cf?style=flat&logo=gnome&logoColor=white)
![Linux](https://img.shields.io/badge/OS-Linux-FCC624?style=flat&logo=linux&logoColor=black)

Lightweight SSH dynamic SOCKS5 tunnel and local HTTP CONNECT bridge designed to bypass restrictive SNI and DPI network filters.

## Architecture

```text
+---------------------------------------------------------------+
| Local Machine                                                 |
|                                                               |
|   Browser / Git / curl ----->  SOCKS5 (127.0.0.1:1080) -----+ |
|                                                             | |
|   Claude Code / Node   ----->  HTTP CONNECT (127.0.0.1:8118)| |
|                                          |                  | |
|                                          v                  | |
|                            SOCKS5 (127.0.0.1:1080) <--------+ |
|                                          |                    |
|                                          v                    |
|                            kantortun-run (ssh -N -D)          |
+------------------------------------------|--------------------+
                                           |
                               SSH Port 22 | (Encrypted Tunnel)
                                           v
                       +---------------------------------------+
                       | Remote VPS                            |
                       |                                       |
                       | Clean Outbound Internet               |
                       +---------------------------------------+
```

## Features

- Dynamic SOCKS5 proxy via user-level SSH tunnel with fast failover keepalive.
- Dedicated local HTTP CONNECT bridge (port 8118) supporting HTTPS tunneling and plain HTTP forwarding for Node.js, undici, and Claude Code.
- TCP half-close support to keep streaming responses and long LLM reasoning sessions alive.
- GNOME top bar indicator for quick toggling, exit IP inspection, and profile switching.
- Zero root dependencies, running entirely under systemd user services.

## Installation

```bash
git clone git@github.com:azrahudaya/kantortun.git ~/Projects/kantortun
cd ~/Projects/kantortun
./install.sh
```

Configure your remote VPS endpoints:

```bash
cp config/kantortun.conf.example ~/.config/kantortun.conf
cp config/kantortun.hosts.example ~/.config/kantortun.hosts
nano ~/.config/kantortun.conf
```

## CLI Usage

```bash
kantortun on            # Start SSH tunnel
kantortun off           # Stop tunnel and reset system proxy
kantortun status        # Check connection status, PID, and exit IP
kantortun test          # Test target domains and Claude Code HTTP bridge
kantortun env           # Output environment variables for shell export
kantortun system-on     # Turn on tunnel and set GNOME system proxy
kantortun system-off    # Disable GNOME system proxy
kantortun autostart on  # Enable tunnel on user login
kantortun use <profile> # Switch active VPS from ~/.config/kantortun.hosts
```

## Claude Code Setup

Claude Code uses `undici`, which requires an HTTP CONNECT proxy rather than SOCKS5. Set the proxy in `~/.claude/settings.json`:

```json
{
  "env": {
    "HTTPS_PROXY": "http://127.0.0.1:8118",
    "HTTP_PROXY": "http://127.0.0.1:8118",
    "NO_PROXY": "localhost,127.0.0.1,::1"
  }
}
```

Ensure the HTTP bridge service is running:

```bash
systemctl --user enable --now kantortun-http.service
```

## Other Applications

Shell session:

```bash
eval $(kantortun env)
```

Git:

```bash
git config --global http.proxy http://127.0.0.1:8118
```

Web Browsers:

Click "System proxy" in the top bar tray icon or run:

```bash
kantortun system-on
```
