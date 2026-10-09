#!/usr/bin/env bash
set -euo pipefail

echo "Menghentikan service kantortun..."
systemctl --user stop kantortun.service kantortun-http.service kantortun-indicator.service 2>/dev/null || true
systemctl --user disable kantortun.service kantortun-http.service kantortun-indicator.service 2>/dev/null || true

echo "Menghapus binary dan service..."
rm -f "$HOME/.local/bin/kantortun"*
rm -rf "$HOME/.local/share/kantortun"
rm -f "$HOME/.config/systemd/user/kantortun"*
rm -f "$HOME/.config/autostart/kantortun-indicator.desktop"

systemctl --user daemon-reload

echo "kantortun berhasil di-uninstall (file config di ~/.config tetap disimpan)."
