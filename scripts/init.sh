#!/bin/bash
set -e

SKILL_DIR="$HOME/.openclaw/workspace/skills/openclaw-backup-skill"
CONFIG_DIR="$HOME/.openclaw-backup"
CONFIG_FILE="$CONFIG_DIR/config.json"

echo "🚀 OpenClaw Backup - 初始化向导"
echo ""

# 创建配置目录
mkdir -p "$CONFIG_DIR"

# 检查是否已初始化
if [ -f "$CONFIG_FILE" ]; then
    echo "⚠️  检测到已有配置文件"
    read -p "是否覆盖现有配置？(y/N): " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo "❌ 初始化已取消"
        exit 0
    fi
fi

# 1. GitHub 仓库配置
echo "📦 步骤 1/4: GitHub 仓库配置"
read -p "GitHub 仓库地址 (SSH格式，如 git@github.com:username/repo.git): " repo_url

if [ -z "$repo_url" ]; then
    echo "❌ 仓库地址不能为空"
    exit 1
fi

# 2. 可选备份项
echo ""
echo "📋 步骤 2/4: 选择备份项"
echo "默认备份: OpenClaw 配置 + Workspace"
echo ""

read -p "是否备份 Claude Code 配置？(y/N): " backup_claude
read -p "是否备份 Codex 配置？(y/N): " backup_codex

# Linux 系统才询问 systemd
backup_systemd="false"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    read -p "是否备份 systemd 服务文件？(Y/n): " backup_systemd_input
    [[ "$backup_systemd_input" =~ ^[Nn]$ ]] || backup_systemd="true"
fi

# 3. 自动备份设置
echo ""
echo "⏰ 步骤 3/4: 自动备份设置"
echo "1) 不需要自动备份"
echo "2) 每天凌晨 2:00"
echo "3) 每周日凌晨 2:00"
read -p "请选择 (1-3): " cron_choice

# 4. 脱敏规则
echo ""
echo "🔒 步骤 4/4: 脱敏规则"
echo "1) 使用默认规则（推荐）"
echo "2) 自定义规则"
read -p "请选择 (1-2): " desensitize_choice

# 生成配置文件
cat > "$CONFIG_FILE" <<EOF
{
  "repository": "$repo_url",
  "branch": "main",
  "backup_items": {
    "openclaw_config": {
      "enabled": true,
      "path": "~/.openclaw/openclaw.json",
      "required": true
    },
    "workspace": {
      "enabled": true,
      "path": "~/.openclaw/workspace/",
      "required": true,
      "exclude": ["node_modules", "*.log", ".DS_Store", "skills"]
    },
    "systemd": {
      "enabled": $backup_systemd,
      "path": "~/.config/systemd/user/openclaw-*.service",
      "required": false,
      "os": ["Linux"]
    },
    "claude_code": {
      "enabled": $([[ "$backup_claude" =~ ^[Yy]$ ]] && echo "true" || echo "false"),
      "path": "~/.claude/",
      "required": false
    },
    "codex": {
      "enabled": $([[ "$backup_codex" =~ ^[Yy]$ ]] && echo "true" || echo "false"),
      "path": "~/.codex/",
      "required": false
    }
  },
  "desensitize": {
    "enabled": true,
    "rules_file": "$CONFIG_DIR/desensitize.json"
  },
  "git": {
    "auto_commit": true,
    "commit_message_prefix": "Backup",
    "auto_push": true,
    "push_retry": 3
  }
}
EOF

# 复制脱敏规则
if [ "$desensitize_choice" == "2" ]; then
    cp "$SKILL_DIR/examples/desensitize.example.json" "$CONFIG_DIR/desensitize.json"
    echo "📝 请编辑 $CONFIG_DIR/desensitize.json 自定义脱敏规则"
else
    cp "$SKILL_DIR/examples/desensitize.example.json" "$CONFIG_DIR/desensitize.json"
fi

# 配置 cron
if [ "$cron_choice" == "2" ] || [ "$cron_choice" == "3" ]; then
    cron_schedule=""
    if [ "$cron_choice" == "2" ]; then
        cron_schedule="0 2 * * *"
    else
        cron_schedule="0 2 * * 0"
    fi
    
    cron_cmd="$SKILL_DIR/scripts/backup.sh"
    (crontab -l 2>/dev/null | grep -v "$cron_cmd"; echo "$cron_schedule $cron_cmd") | crontab -
    echo "✅ 已配置自动备份"
fi

echo ""
echo "✅ 初始化完成！"
echo ""
echo "配置文件: $CONFIG_FILE"
echo ""
echo "下一步："
echo "1. 执行首次备份: bash $SKILL_DIR/scripts/backup.sh"
echo "2. 查看状态: bash $SKILL_DIR/scripts/status.sh"
