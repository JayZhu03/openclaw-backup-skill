#!/bin/bash
set -e

BACKUP_DIR="$HOME/openclaw-backup"

if [ ! -d "$BACKUP_DIR/.git" ]; then
    echo "❌ 备份仓库不存在"
    exit 1
fi

if [ -z "$1" ]; then
    echo "用法: $0 <commit-hash>"
    echo ""
    echo "可用的备份版本："
    cd "$BACKUP_DIR"
    git log --oneline -10
    exit 1
fi

COMMIT_HASH="$1"

cd "$BACKUP_DIR"

# 验证 commit 是否存在
if ! git cat-file -e "$COMMIT_HASH^{commit}" 2>/dev/null; then
    echo "❌ 无效的 commit hash: $COMMIT_HASH"
    exit 1
fi

echo "🔄 回滚到版本: $COMMIT_HASH"

# 创建安全点
SAFETY_BACKUP="$HOME/.openclaw-backup-safety-$(date +%s)"
mkdir -p "$SAFETY_BACKUP"
[ -f ~/.openclaw/openclaw.json ] && cp ~/.openclaw/openclaw.json "$SAFETY_BACKUP/"
[ -d ~/.openclaw/workspace ] && cp -r ~/.openclaw/workspace "$SAFETY_BACKUP/"
echo "  → 已创建安全点: $SAFETY_BACKUP"

# 回滚 Git 仓库
git checkout "$COMMIT_HASH"

# 恢复配置
echo "  → 恢复配置..."
[ -f "$BACKUP_DIR/config-files/openclaw.json" ] && cp "$BACKUP_DIR/config-files/openclaw.json" ~/.openclaw/openclaw.json
[ -d "$BACKUP_DIR/workspace-files" ] && rsync -a "$BACKUP_DIR/workspace-files/" ~/.openclaw/workspace/

echo "✅ 回滚完成！"
echo ""
echo "⚠️  重要提示:"
echo "1. 敏感信息已脱敏，需要手动填充"
echo "2. 如需撤销回滚: cp -r $SAFETY_BACKUP/* ~/.openclaw/"
echo "3. 重启 Gateway: systemctl --user restart openclaw-gateway"
