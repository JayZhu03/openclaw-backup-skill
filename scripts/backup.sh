#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CONFIG_DIR="$HOME/.openclaw-backup"
CONFIG_FILE="$CONFIG_DIR/config.json"
BACKUP_DIR="$HOME/openclaw-backup"

# 错误处理函数
error_exit() {
    echo -e "${RED}❌ 错误: $1${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}⚠️  警告: $1${NC}"
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
        error_exit "缺少依赖: ${missing_deps[*]}. 请先安装这些工具。"
    fi
}

# 读取 JSON 配置（纯 Bash 实现）
get_json_value() {
    local json_file="$1"
    local key_path="$2"
    
    # 简单的 JSON 解析（适用于简单结构）
    grep -o "\"$key_path\": *\"[^\"]*\"" "$json_file" | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/'
}

check_json_bool() {
    local json_file="$1"
    local key_path="$2"
    
    grep -q "\"$key_path\"[^}]*\"enabled\": *true" "$json_file"
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
