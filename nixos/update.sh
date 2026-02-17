#!/usr/bin/env bash

set -euo pipefail

SOURCE="$HOME/dotfiles/nixos"
DEST="/etc/nixos"

if [[ ! -d "$SOURCE" ]]; then
  echo "❌ Ошибка: $SOURCE не существует!"
  exit 1
fi

echo "🔒 Введите sudo пароль для копирования $SOURCE → $DEST..."
sudo rsync -a --delete --backup --backup-dir="/etc/nixos-backup-$(date +%Y%m%d-%H%M)" "$SOURCE/" "$DEST/"

echo "✅ Готово! Бэкап в /etc/nixos-backup-*. Запустите sudo nixos-rebuild switch."
