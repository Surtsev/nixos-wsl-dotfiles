#!/usr/bin/env bash

set -euo pipefail # Безопасность: exit on error

SOURCE="$HOME/dotfiles/home-manager"
DEST="$HOME/.config/home-manager"

if [[ ! -d "$SOURCE" ]]; then
  echo "❌ Ошибка: $SOURCE не существует!"
  exit 1
fi

echo "📁 Копируем $SOURCE → $DEST..."
rsync -a --delete --backup --backup-dir="$HOME/.config/home-manager-backup-$(date +%Y%m%d-%H%M)" "$SOURCE/" "$DEST/"

echo "✅ Готово! Бэкап в ~/.config/home-manager-backup-*. Запустите home-manager switch."
