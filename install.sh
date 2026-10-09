#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Memasang kantortun ke lingkungan user..."

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/kantortun"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$HOME/.config/autostart"

# Pasang script eksekutabel
cp -f "$SCRIPT_DIR/bin/"* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/kantortun"*

# Pasang icon
cp -f "$SCRIPT_DIR/icons/"*.svg "$HOME/.local/share/kantortun/"

# Pasang systemd user units
cp -f "$SCRIPT_DIR/systemd/"*.service "$HOME/.config/systemd/user/"

# Pasang autostart desktop entry
cp -f "$SCRIPT_DIR/autostart/"*.desktop "$HOME/.config/autostart/"

# Siapkan config awal jika belum ada
if [ ! -f "$HOME/.config/kantortun.conf" ]; then
  cp "$SCRIPT_DIR/config/kantortun.conf.example" "$HOME/.config/kantortun.conf"
  echo "Dibuat template konfigurasi baru: ~/.config/kantortun.conf (sesuaikan dengan VPS Anda)"
fi

if [ ! -f "$HOME/.config/kantortun.hosts" ]; then
  cp "$SCRIPT_DIR/config/kantortun.hosts.example" "$HOME/.config/kantortun.hosts"
  echo "Dibuat template daftar host: ~/.config/kantortun.hosts"
fi

# Reload systemd
systemctl --user daemon-reload

echo "Instalasi selesai."
echo "Untuk mengaktifkan proxy CLI HTTP otomatis saat boot:"
echo "  systemctl --user enable --now kantortun-http.service"
echo "Untuk menyalakan tray indicator:"
echo "  systemctl --user start kantortun-indicator.service"
echo "Gunakan 'kantortun status' untuk memeriksa."
