#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG_DIR="$HOME/.openclaw-backup"
CONFIG_FILE="$CONFIG_DIR/config.json"
BACKUP_DIR="$HOME/openclaw-backup"

# 错误处理
error_exit() {
    echo -e "${RED}❌ 错误: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 检查依赖
check_dependencies() {
    local missing_deps=()
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    command -v rsync >/dev/null 2>&1 || missing_deps+=("rsync")
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error_exit "缺少依赖: ${missing_deps[*]}"
    fi
}

# 读取 JSON 配置
get_json_value() {
    local json_file="$1"
    local key="$2"
    grep -o "\"$key\": *\"[^\"]*\"" "$json_file" | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/'
}

check_json_bool() {
    local json_file="$1"
    local key="$2"
    
    # 使用 Python 解析 JSON
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import json,sys; c=json.load(open('$json_file')); sys.exit(0 if c['backup_items']['$key']['enabled'] else 1)" 2>/dev/null
    else
        # 回退方案：grep 多行
        grep -A 10 "\"$key\"" "$json_file" | grep '"enabled"' | grep -q 'true'
    fi
}

# 自动检测路径
detect_openclaw_config() {
    if [ -f ~/.openclaw/openclaw.json ]; then
        echo ~/.openclaw/openclaw.json
    else
        find ~ -maxdepth 3 -name "openclaw.json" -type f 2>/dev/null | head -1
    fi
}

detect_openclaw_workspace() {
    if [ -d ~/.openclaw/workspace ]; then
        echo ~/.openclaw/workspace
    else
        local config=$(detect_openclaw_config)
        if [ -n "$config" ]; then
            echo "$(dirname "$config")/workspace"
        fi
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

echo "📦 开始备份 OpenClaw 配置..."

# 检查依赖
check_dependencies

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    error_exit "配置文件不存在: $CONFIG_FILE\n请先运行 init.sh 初始化配置"
fi

# 读取配置
REPO=$(get_json_value "$CONFIG_FILE" "repository")
BRANCH=$(get_json_value "$CONFIG_FILE" "branch")

if [ -z "$REPO" ]; then
    error_exit "配置文件中未找到仓库地址"
fi

echo "  → 仓库: $REPO"
echo "  → 分支: $BRANCH"

# 初始化 Git 仓库
if [ ! -d "$BACKUP_DIR/.git" ]; then
    echo "  → 初始化备份仓库..."
    mkdir -p "$BACKUP_DIR"
    cd "$BACKUP_DIR"
    git init
    git remote add origin "$REPO" 2>/dev/null || git remote set-url origin "$REPO"
    git checkout -b "$BRANCH" 2>/dev/null || true
    git config user.email "backup@openclaw.local"
    git config user.name "OpenClaw Backup"
else
    cd "$BACKUP_DIR"
    git pull origin "$BRANCH" 2>/dev/null || true
fi

# 清理旧备份
rm -rf "$BACKUP_DIR/workspace-files" "$BACKUP_DIR/config-files"
mkdir -p "$BACKUP_DIR/workspace-files" "$BACKUP_DIR/config-files"

# 备份 openclaw.json
if check_json_bool "$CONFIG_FILE" "openclaw_config"; then
    OPENCLAW_CONFIG=$(detect_openclaw_config)
    if [ -n "$OPENCLAW_CONFIG" ] && [ -f "$OPENCLAW_CONFIG" ]; then
        echo "  → 脱敏 openclaw.json..."
        cp "$OPENCLAW_CONFIG" "$BACKUP_DIR/config-files/openclaw.json"
        
        # 脱敏
        if [ -f "$CONFIG_DIR/desensitize.json" ]; then
            sed -i 's/"token": *"[^"]*"/"token": "<REDACTED>"/g' "$BACKUP_DIR/config-files/openclaw.json"
            sed -i 's/"apiKey": *"[^"]*"/"apiKey": "<REDACTED>"/g' "$BACKUP_DIR/config-files/openclaw.json"
        fi
    else
        echo "  ⚠️  未找到 openclaw.json"
    fi
fi

# 备份 workspace
if check_json_bool "$CONFIG_FILE" "workspace"; then
    WORKSPACE_PATH=$(detect_openclaw_workspace)
    if [ -n "$WORKSPACE_PATH" ] && [ -d "$WORKSPACE_PATH" ]; then
        echo "  → 备份 workspace..."
        rsync -a --exclude='node_modules' --exclude='*.log' --exclude='.DS_Store' --exclude='skills' --exclude='.git' \
            "$WORKSPACE_PATH/" "$BACKUP_DIR/workspace-files/"
    else
        echo "  ⚠️  未找到 workspace 目录"
    fi
fi

# 备份 Claude Code
if check_json_bool "$CONFIG_FILE" "claude_code"; then
    CLAUDE_PATH=$(detect_claude_path)
    if [ -n "$CLAUDE_PATH" ] && [ -d "$CLAUDE_PATH" ]; then
        echo "  → 备份 Claude Code 配置..."
        mkdir -p "$BACKUP_DIR/config-files/claude"
        rsync -a --exclude='.git' "$CLAUDE_PATH/" "$BACKUP_DIR/config-files/claude/"
    else
        echo "  ⚠️  未找到 Claude Code 目录"
    fi
fi

# 备份 Codex
if check_json_bool "$CONFIG_FILE" "codex"; then
    CODEX_PATH=$(detect_codex_path)
    if [ -n "$CODEX_PATH" ] && [ -d "$CODEX_PATH" ]; then
        echo "  → 备份 Codex 配置..."
        mkdir -p "$BACKUP_DIR/config-files/codex"
        rsync -a --exclude='.git' "$CODEX_PATH/" "$BACKUP_DIR/config-files/codex/"
    else
        echo "  ⚠️  未找到 Codex 目录"
    fi
fi

# 备份 systemd
if check_json_bool "$CONFIG_FILE" "systemd"; then
    if [ -d ~/.config/systemd/user ]; then
        echo "  → 备份 systemd 服务..."
        mkdir -p "$BACKUP_DIR/config-files/systemd"
        cp ~/.config/systemd/user/openclaw-*.service "$BACKUP_DIR/config-files/systemd/" 2>/dev/null || true
    fi
fi

# 提交到 Git
echo "  → 提交到 Git..."
git add -A
git commit -m "Backup $(date '+%Y-%m-%d %H:%M:%S')" || echo "  ℹ️  没有变化"

# 推送到 GitHub
echo "  → 推送到 GitHub..."
INSTEADOF_RULES=$(git config --global --get-all url.https://github.com/.insteadOf 2>/dev/null || true)
if [ -n "$INSTEADOF_RULES" ]; then
    git config --global --unset-all url.https://github.com/.insteadOf
fi

git push origin "$BRANCH" || {
    echo -e "${RED}❌ 推送失败，请检查 SSH key 配置${NC}"
    if [ -n "$INSTEADOF_RULES" ]; then
        echo "$INSTEADOF_RULES" | while read rule; do
            git config --global --add url.https://github.com/.insteadOf "$rule"
        done
    fi
    exit 1
}

if [ -n "$INSTEADOF_RULES" ]; then
    echo "$INSTEADOF_RULES" | while read rule; do
        git config --global --add url.https://github.com/.insteadOf "$rule"
    done
fi

success "备份完成！"
