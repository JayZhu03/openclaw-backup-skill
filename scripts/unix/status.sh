#!/bin/bash

CONFIG_DIR="$HOME/.openclaw-backup"
CONFIG_FILE="$CONFIG_DIR/config.json"
BACKUP_DIR="$HOME/openclaw-backup"

echo "📊 OpenClaw Backup 状态"
echo ""

# 配置状态
if [ -f "$CONFIG_FILE" ]; then
    echo "✅ 配置文件: $CONFIG_FILE"
    REPO=$(grep -o '"repository": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    echo "   仓库: $REPO"
else
    echo "❌ 配置文件不存在，请先运行 init.sh"
    exit 1
fi

# 备份仓库状态
if [ -d "$BACKUP_DIR/.git" ]; then
    cd "$BACKUP_DIR"
    echo ""
    echo "✅ 备份仓库: $BACKUP_DIR"
    LAST_COMMIT=$(git log -1 --format="%h - %s (%ar)")
    echo "   最后备份: $LAST_COMMIT"
    
    # 检查是否有未推送的提交
    UNPUSHED=$(git log @{u}.. --oneline 2>/dev/null | wc -l)
    if [ "$UNPUSHED" -gt 0 ]; then
        echo "   ⚠️  有 $UNPUSHED 个未推送的提交"
    fi
else
    echo ""
    echo "⚠️  备份仓库不存在，请先执行 backup.sh"
fi

# 备份项状态
echo ""
echo "📋 备份项:"
grep -q '"openclaw_config".*"enabled": *true' "$CONFIG_FILE" && echo "   ✅ OpenClaw 配置"
grep -q '"workspace".*"enabled": *true' "$CONFIG_FILE" && echo "   ✅ Workspace"
grep -q '"claude_code".*"enabled": *true' "$CONFIG_FILE" && echo "   ✅ Claude Code"
grep -q '"codex".*"enabled": *true' "$CONFIG_FILE" && echo "   ✅ Codex"
grep -q '"systemd".*"enabled": *true' "$CONFIG_FILE" && echo "   ✅ systemd 服务"

echo ""
