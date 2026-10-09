# kantortun

Bypass filter SNI dan DPI jaringan kantor menggunakan VPS pribadi via SSH dynamic SOCKS5 dan local HTTP CONNECT bridge.

## Latar Belakang

Filter jaringan kantor umumnya menerapkan SNI-based Deep Packet Inspection (DPI) pada port TCP 443. Ketika TLS ClientHello membawa SNI domain yang diblokir, koneksi langsung di-reset, sehingga penggantian DNS / DoH / DoT tidak berpengaruh.

Jalur yang tembus:
- Port 22 (SSH) ke VPS pribadi
- TCP port 80/443 langsung ke VPS pribadi

kantortun membungkus seluruh trafik keluar ke dalam SSH tunnel terenkripsi sehingga DPI kantor hanya melihat sesi SSH biasa.

## Arsitektur

1. **kantortun.service (`kantortun-run`)**
   Unit systemd user yang menjalankan `ssh -N -D 127.0.0.1:1080` ke VPS dengan keepalive dan auto-restart.

2. **kantortun-http.service (`kantortun-httpd`)**
   Daemon bridge HTTP CONNECT di port 8118 (`http://127.0.0.1:8118`) yang meneruskan koneksi HTTPS ke SOCKS5 1080.
   Diperlukan karena CLI berbasis Node.js / undici (seperti Claude Code) hanya memahami HTTP CONNECT proxy dan menolak SOCKS5 di `HTTPS_PROXY`.

3. **kantortun-indicator.service (`kantortun-indicator`)**
   Tray icon di top bar desktop GNOME untuk menyalakan/mematikan tunnel, sinkronisasi system proxy GNOME, melihat status IP keluar, dan berpindah VPS exit.

## Instalasi

```bash
git clone git@github.com:azrahudaya/kantortun.git ~/Projects/kantortun
cd ~/Projects/kantortun
./install.sh
```

Salin dan sesuaikan konfigurasi VPS:
```bash
cp config/kantortun.conf.example ~/.config/kantortun.conf
cp config/kantortun.hosts.example ~/.config/kantortun.hosts
nano ~/.config/kantortun.conf
```

## Penggunaan CLI

```bash
kantortun on            # Nyalakan tunnel
kantortun off           # Matikan tunnel dan reset proxy sistem
kantortun status        # Cek status koneksi, PID SSH, dan IP keluar
kantortun test          # Uji akses domain yang diblokir
kantortun env           # Cetak environment variable proxy
kantortun system-on     # Nyalakan tunnel dan pasang proxy GNOME (Chrome/Firefox otomatis ikut)
kantortun system-off    # Matikan proxy GNOME
kantortun autostart on  # Jalankan tunnel otomatis saat login
kantortun use <nama>    # Pindah VPS tujuan dari daftar ~/.config/kantortun.hosts
```

## Konfigurasi untuk Claude Code

Claude Code menggunakan `undici` yang memerlukan HTTP CONNECT proxy. Setel proxy di `~/.claude/settings.json`:

```json
{
  "env": {
    "HTTPS_PROXY": "http://127.0.0.1:8118",
    "HTTP_PROXY": "http://127.0.0.1:8118",
    "NO_PROXY": "localhost,127.0.0.1,::1"
  }
}
```

Pastikan service `kantortun-http.service` aktif:
```bash
systemctl --user enable --now kantortun-http.service
```

## Konfigurasi Aplikasi Lain

CLI / Terminal umum:
```bash
eval $(kantortun env)
```

Git:
```bash
git config --global http.proxy http://127.0.0.1:8118
```
atau via SOCKS:
```bash
git config --global http.proxy socks5h://127.0.0.1:1080
```

Browser:
Cukup aktifkan fitur "System proxy" dari tray icon atau jalankan:
```bash
kantortun system-on
```
