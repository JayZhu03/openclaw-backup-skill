#!/bin/bash

BACKUP_DIR="$HOME/openclaw-backup"

if [ ! -d "$BACKUP_DIR/.git" ]; then
    echo "❌ 备份仓库不存在"
    exit 1
fi

cd "$BACKUP_DIR"

echo "📜 备份历史："
git log --oneline --decorate --all

if [ -n "$1" ]; then
    echo ""
    echo "📄 文件历史: $1"
    git log --oneline -- "$1"
fi
