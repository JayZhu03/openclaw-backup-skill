#!/bin/bash
set -e

BACKUP_DIR="$HOME/openclaw-backup"

if [ ! -d "$BACKUP_DIR/.git" ]; then
    echo "❌ 备份仓库不存在，请先执行 backup.sh"
    exit 1
fi

cd "$BACKUP_DIR"

# 解析参数
RESTORE_ALL=false
RESTORE_CONFIG=false
RESTORE_WORKSPACE=false
RESTORE_CLAUDE=false
RESTORE_CODEX=false
RESTORE_SYSTEMD=false

if [ "$1" == "--all" ]; then
    RESTORE_ALL=true
elif [ "$1" == "--config" ]; then
    RESTORE_CONFIG=true
elif [ "$1" == "--workspace" ]; then
    RESTORE_WORKSPACE=true
elif [ "$1" == "--claude" ]; then
    RESTORE_CLAUDE=true
elif [ "$1" == "--codex" ]; then
    RESTORE_CODEX=true
elif [ "$1" == "--systemd" ]; then
    RESTORE_SYSTEMD=true
else
    echo "用法: $0 [--all|--config|--workspace|--claude|--codex|--systemd]"
    exit 1
fi

echo "🔄 开始恢复配置..."

# 恢复前创建安全点
SAFETY_BACKUP="$HOME/.openclaw-backup-safety-$(date +%s)"
mkdir -p "$SAFETY_BACKUP"
[ -f ~/.openclaw/openclaw.json ] && cp ~/.openclaw/openclaw.json "$SAFETY_BACKUP/"
[ -d ~/.openclaw/workspace ] && cp -r ~/.openclaw/workspace "$SAFETY_BACKUP/"
echo "  → 已创建安全点: $SAFETY_BACKUP"

# 恢复 openclaw.json
if [ "$RESTORE_ALL" == "true" ] || [ "$RESTORE_CONFIG" == "true" ]; then
    if [ -f "$BACKUP_DIR/config-files/openclaw.json" ]; then
        echo "  → 恢复 openclaw.json..."
        echo "⚠️  警告: 备份文件中的敏感信息已脱敏，需要手动填充"
        cp "$BACKUP_DIR/config-files/openclaw.json" ~/.openclaw/openclaw.json
    fi
fi

# 恢复 workspace
if [ "$RESTORE_ALL" == "true" ] || [ "$RESTORE_WORKSPACE" == "true" ]; then
    if [ -d "$BACKUP_DIR/workspace-files" ]; then
        echo "  → 恢复 workspace..."
        rsync -a "$BACKUP_DIR/workspace-files/" ~/.openclaw/workspace/
    fi
fi

# 恢复 Claude Code
if [ "$RESTORE_ALL" == "true" ] || [ "$RESTORE_CLAUDE" == "true" ]; then
    if [ -d "$BACKUP_DIR/config-files/claude" ]; then
        echo "  → 恢复 Claude Code 配置..."
        rsync -a "$BACKUP_DIR/config-files/claude/" ~/.claude/
    fi
fi

# 恢复 Codex
if [ "$RESTORE_ALL" == "true" ] || [ "$RESTORE_CODEX" == "true" ]; then
    if [ -d "$BACKUP_DIR/config-files/codex" ]; then
        echo "  → 恢复 Codex 配置..."
        rsync -a "$BACKUP_DIR/config-files/codex/" ~/.codex/
    fi
fi

# 恢复 systemd
if [ "$RESTORE_ALL" == "true" ] || [ "$RESTORE_SYSTEMD" == "true" ]; then
    if [ -d "$BACKUP_DIR/config-files/systemd" ]; then
        echo "  → 恢复 systemd 服务..."
        mkdir -p ~/.config/systemd/user
        cp "$BACKUP_DIR/config-files/systemd/"*.service ~/.config/systemd/user/ 2>/dev/null || true
    fi
fi

echo "✅ 恢复完成！"
echo ""
echo "⚠️  重要提示:"
echo "1. 敏感信息已脱敏，需要手动填充 Token 和 API Key"
echo "2. 如需回滚此次恢复，运行: cp -r $SAFETY_BACKUP/* ~/.openclaw/"
echo "3. 重启 OpenClaw Gateway: systemctl --user restart openclaw-gateway"
