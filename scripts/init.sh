#!/bin/bash
set -e

SKILL_DIR="$HOME/.openclaw/workspace/skills/openclaw-backup-skill"
CONFIG_DIR="$HOME/.openclaw-backup"
CONFIG_FILE="$CONFIG_DIR/config.json"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error_exit() {
    echo -e "${RED}❌ $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 路径检测
detect_openclaw_config() {
    if [ -f ~/.openclaw/openclaw.json ]; then
        echo ~/.openclaw/openclaw.json
    else
        find ~ -maxdepth 3 -name "openclaw.json" -type f 2>/dev/null | head -1
    fi
}

detect_claude_path() {
    if [ -d ~/.claude ]; then
        echo ~/.claude
    elif [ -d ~/Library/Application\ Support/Claude ]; then
        echo ~/Library/Application\ Support/Claude
    fi
}

detect_codex_path() {
    if [ -d ~/.codex ]; then
        echo ~/.codex
    fi
}

# 解析命令行参数
REPO=""
CLAUDE_CODE="ask"
CODEX="ask"
SYSTEMD="ask"
CRON_CHOICE="ask"
INTERACTIVE=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --repo)
            REPO="$2"
            shift 2
            ;;
        --claude-code)
            CLAUDE_CODE="$2"
            INTERACTIVE=false
            shift 2
            ;;
        --codex)
            CODEX="$2"
            INTERACTIVE=false
            shift 2
            ;;
        --systemd)
            SYSTEMD="$2"
            INTERACTIVE=false
            shift 2
            ;;
        --auto-backup)
            CRON_CHOICE="$2"
            INTERACTIVE=false
            shift 2
            ;;
        --non-interactive)
            INTERACTIVE=false
            shift
            ;;
        *)
            echo "未知参数: $1"
            exit 1
            ;;
    esac
done

echo "🚀 OpenClaw Backup - 初始化向导"
echo ""

# 创建配置目录
mkdir -p "$CONFIG_DIR"

# 检查是否已初始化
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}⚠️  检测到已有配置文件${NC}"
    if [ "$INTERACTIVE" = true ]; then
        read -p "是否覆盖现有配置？(y/N): " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            echo "❌ 初始化已取消"
            exit 0
        fi
    fi
fi

# 步骤 1: GitHub 仓库配置
if [ "$INTERACTIVE" = true ]; then
    echo "📦 步骤 1/4: GitHub 仓库配置"
    read -p "GitHub 仓库地址 (SSH格式): " repo_url
    REPO="$repo_url"
else
    echo "📦 GitHub 仓库: $REPO"
fi

if [ -z "$REPO" ]; then
    error_exit "仓库地址不能为空"
fi

# 步骤 2: 可选备份项
echo ""
echo "📋 步骤 2/4: 选择备份项"
echo "默认备份: OpenClaw 配置 + Workspace"
echo ""

# Claude Code
if [ "$CLAUDE_CODE" = "ask" ]; then
    CLAUDE_DETECTED=$(detect_claude_path)
    if [ -n "$CLAUDE_DETECTED" ]; then
        read -p "检测到 Claude Code ($CLAUDE_DETECTED)，是否备份？(y/N): " backup_claude
    else
        read -p "是否备份 Claude Code 配置？(y/N): " backup_claude
    fi
    CLAUDE_CODE="$backup_claude"
fi

# Codex
if [ "$CODEX" = "ask" ]; then
    CODEX_DETECTED=$(detect_codex_path)
    if [ -n "$CODEX_DETECTED" ]; then
        read -p "检测到 Codex ($CODEX_DETECTED)，是否备份？(y/N): " backup_codex
    else
        read -p "是否备份 Codex 配置？(y/N): " backup_codex
    fi
    CODEX="$backup_codex"
fi

# systemd
backup_systemd="false"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ "$SYSTEMD" = "ask" ]; then
        read -p "是否备份 systemd 服务文件？(Y/n): " backup_systemd_input
        [[ "$backup_systemd_input" =~ ^[Nn]$ ]] || backup_systemd="true"
    else
        [[ "$SYSTEMD" =~ ^[Yy]$ ]] && backup_systemd="true"
    fi
fi

# 步骤 3: 自动备份设置
echo ""
echo "⏰ 步骤 3/4: 自动备份设置"
if [ "$CRON_CHOICE" = "ask" ]; then
    echo "1) 不需要自动备份"
    echo "2) 每天凌晨 2:00"
    echo "3) 每周日凌晨 2:00"
    read -p "请选择 (1-3): " cron_choice
    CRON_CHOICE="$cron_choice"
fi

# 步骤 4: 脱敏规则
echo ""
echo "🔒 步骤 4/4: 脱敏规则"
if [ "$INTERACTIVE" = true ]; then
    echo "1) 使用默认规则（推荐）"
    echo "2) 自定义规则"
    read -p "请选择 (1-2): " desensitize_choice
else
    desensitize_choice="1"
fi

# 生成配置文件
cat > "$CONFIG_FILE" <<EOF
{
  "repository": "$REPO",
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
      "enabled": $([[ "$CLAUDE_CODE" =~ ^[Yy]$ ]] && echo "true" || echo "false"),
      "path": "~/.claude/",
      "required": false
    },
    "codex": {
      "enabled": $([[ "$CODEX" =~ ^[Yy]$ ]] && echo "true" || echo "false"),
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
if [ "$CRON_CHOICE" == "2" ] || [ "$CRON_CHOICE" == "3" ]; then
    cron_schedule=""
    if [ "$CRON_CHOICE" == "2" ]; then
        cron_schedule="0 2 * * *"
    else
        cron_schedule="0 2 * * 0"
    fi
    
    cron_cmd="$SKILL_DIR/scripts/backup.sh"
    (crontab -l 2>/dev/null | grep -v "$cron_cmd"; echo "$cron_schedule $cron_cmd") | crontab -
    success "已配置自动备份"
fi

echo ""
success "初始化完成！"
echo ""
echo "配置文件: $CONFIG_FILE"
echo ""
echo "下一步："
echo "1. 执行首次备份: bash $SKILL_DIR/scripts/backup.sh"
echo "2. 查看状态: bash $SKILL_DIR/scripts/status.sh"
