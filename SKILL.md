# OpenClaw Backup Skill

---
name: openclaw-backup-skill
description: "自动备份 OpenClaw 配置到 GitHub 私有仓库，支持版本管理、一键恢复和自定义备份描述。跨平台支持 Linux/macOS/Windows。使用场景：'备份配置'、'恢复配置'、'更新前备份'、'查看备份历史'、'回滚到指定版本'。"
---

自动备份 OpenClaw 配置到 GitHub 私有仓库，支持版本管理、一键恢复和自定义备份描述。

> ⚠️ **重要警告** ⚠️  
> **恢复操作会覆盖当前配置！备份中的敏感信息已脱敏（Token 等变成 `<REDACTED>`）**  
> **直接恢复会导致 OpenClaw 无法启动！恢复后必须手动填写 Token 等敏感信息。**

## 使用场景

- 📦 定期备份 OpenClaw 配置和 Workspace
- 🔄 版本管理和历史追溯
- 🛡️ 配置修改前创建安全点
- 💾 多设备配置同步
- 🔙 快速恢复到历史版本
- 📝 重要操作前标记备份（如"更新前的备份"）

## 依赖

### Linux / macOS
- Git >= 2.0
- rsync >= 3.0
- Bash 4.0+
- SSH 密钥（用于 GitHub）

### Windows
- Git >= 2.0
- PowerShell 5.0+
- SSH 密钥（用于 GitHub）

## 触发条件

当用户提到以下关键词时使用此 skill：
- "备份配置"、"backup"、"创建备份"、"初始化备份"
- "恢复配置"、"restore"、"回滚"
- "查看备份历史"、"backup history"
- 修改 openclaw.json 等核心配置前

**当用户要求恢复配置时，必须先警告用户上述风险！**

## AI 引导式配置（推荐）

当用户说"初始化 openclaw-backup" 或 "配置备份"时，使用以下流程：

### 步骤 1: 收集信息

询问用户以下问题：

1. **GitHub 仓库地址？**
   - 格式：`git@github.com:username/repo.git`（SSH）或 `https://github.com/username/repo.git`（HTTPS）
   - 建议使用 SSH 格式
   - ⚠️ **必须使用私有仓库**（备份包含敏感信息）

2. **需要备份哪些内容？**
   - OpenClaw 配置（必选）
   - Workspace 工作空间（必选）
   - Claude Code 配置（可选）
   - Codex 配置（可选）
   - systemd 服务文件（可选，仅 Linux）

3. **是否需要自动备份？**
   - 不需要
   - 每天凌晨 2:00
   - 每周日凌晨 2:00

### 步骤 1.5: 安全检查（重要）

在生成配置前，执行以下检查：

**1. SSH 密钥检查（如果使用 SSH 格式）**
```bash
# 检查 SSH 密钥是否存在
if [ ! -f ~/.ssh/id_rsa ] && [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "⚠️ 警告：未检测到 SSH 密钥"
    echo "请先配置 GitHub SSH 密钥："
    echo "1. 生成密钥：ssh-keygen -t ed25519 -C 'your_email@example.com'"
    echo "2. 添加到 GitHub：https://github.com/settings/keys"
    exit 1
fi

# 测试 SSH 连接
ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" || {
    echo "⚠️ 警告：SSH 连接测试失败"
    echo "请确保已将 SSH 公钥添加到 GitHub"
}
```

**2. 仓库可见性检查**
```bash
# 提取仓库信息
REPO_URL="用户提供的仓库地址"
if [[ "$REPO_URL" =~ github.com[:/]([^/]+)/([^/.]+) ]]; then
    REPO_OWNER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    
    # 检查仓库可见性
    REPO_INFO=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME")
    
    if echo "$REPO_INFO" | grep -q '"private": false'; then
        # 明确检测到公开仓库
        echo "🚨 严重警告：检测到公开仓库！"
        echo "备份包含敏感信息（Token、API Key 等），即使脱敏也可能有遗漏"
        echo "强烈建议使用私有仓库！"
        echo ""
        echo "是否继续？(yes/no)"
        # 等待用户确认
    elif echo "$REPO_INFO" | grep -q '"private": true'; then
        # 私有仓库（已授权访问）
        echo "✅ 检测到私有仓库"
    else
        # 404 或其他错误 - 可能是不存在或私有仓库（未授权）
        echo "⚠️ 无法验证仓库可见性（可能是私有仓库或不存在）"
        echo "请手动确认："
        echo "  - 如果仓库已存在，确保它是私有的"
        echo "  - 如果是新仓库，创建时选择私有"
        echo ""
        echo "确认后继续配置"
    fi
fi
```

如果检查失败，告诉用户如何修复，然后停止配置流程。

### 步骤 2: 生成配置

根据用户回答，直接生成配置文件：

```bash
mkdir -p ~/.openclaw-backup

# 创建配置文件
cat > ~/.openclaw-backup/config.json <<'EOF'
{
  "repository": "用户提供的仓库地址",
  "branch": "main",
  "backup_items": {
    "openclaw_config": {"enabled": true, "path": "~/.openclaw/openclaw.json", "required": true},
    "workspace": {"enabled": true, "path": "~/.openclaw/workspace/", "required": true},
    "claude_code": {"enabled": false, "path": "~/.claude/", "required": false},
    "codex": {"enabled": false, "path": "~/.codex/", "required": false},
    "systemd": {"enabled": false, "path": "~/.config/systemd/user/openclaw-*.service", "required": false}
  },
  "desensitize": {"enabled": true, "rules_file": "~/.openclaw-backup/desensitize.json"},
  "git": {"auto_commit": true, "auto_push": true}
}
EOF

# 复制脱敏规则
cp ~/.openclaw/workspace/skills/openclaw-backup-skill/examples/desensitize.example.json ~/.openclaw-backup/desensitize.json
```

### 步骤 3: 配置 cron（可选）

如果用户选择自动备份：

```bash
# 每天凌晨 2:00
(crontab -l 2>/dev/null | grep -v "openclaw-backup"; echo "0 2 * * * bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/backup.sh") | crontab -

# 或每周日凌晨 2:00
(crontab -l 2>/dev/null | grep -v "openclaw-backup"; echo "0 2 * * 0 bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/backup.sh") | crontab -
```

### 步骤 4: 完成提示

告诉用户：
```
✅ 配置完成！

下一步：
1. 执行首次备份：bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/backup.sh
2. 查看状态：bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/status.sh

配置文件位置：~/.openclaw-backup/config.json
如需修改，可以直接编辑该文件。
```

---

## 使用方法

### 方式 1: AI 引导配置（推荐，适合聊天软件）

用户说："帮我初始化 openclaw-backup，仓库是 git@github.com:xxx/xxx.git，需要备份 Claude Code"

AI 直接生成配置文件，无需交互。

### 方式 2: 交互式向导（适合终端）

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/init.sh
```

### 方式 3: 命令行参数（适合脚本调用）

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/init.sh \
  --repo "git@github.com:username/repo.git" \
  --claude-code yes \
  --codex no \
  --auto-backup no \
  --non-interactive
```

---

## 核心功能

**跨平台支持：**
- 脚本会自动检测操作系统
- Linux/macOS：使用 bash 脚本（`scripts/unix/`）
- Windows：使用 PowerShell 脚本（`scripts/windows/`）
- 使用统一的包装脚本，无需手动选择

### 执行备份

**AI 识别自定义描述：**

当用户说以下内容时，AI 应识别并添加自定义描述：
- "更新前备份一下" → `--message "更新前的备份"`
- "测试前先备份" → `--message "测试前的备份"`
- "重要修改前备份" → `--message "重要修改前的备份"`

**Linux/macOS：**
```bash
# 普通备份
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/unix/backup.sh

# 带自定义描述的备份
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/unix/backup.sh --message "更新前的备份"
```

**Windows：**
```powershell
# 普通备份
powershell ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/windows/backup.ps1

# 带自定义描述的备份
powershell ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/windows/backup.ps1 -Message "更新前的备份"
```

**自动选择（推荐）：**
```bash
~/.openclaw/workspace/skills/openclaw-backup-skill/backup
```

自动完成：
- 脱敏敏感信息
- 提交到 Git（包含自定义描述）
- 推送到 GitHub
- 提交到 Git
- 推送到 GitHub

### 查看状态

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/status.sh
```

显示：
- 最后备份时间
- 仓库状态
- 配置摘要

### 查看历史

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/history.sh
```

列出所有备份版本和提交信息。

### 恢复配置

**⚠️ AI 执行前必须确认：**

当用户要求恢复配置时，AI 必须：
1. 先警告用户风险
2. 等待用户明确确认（用户回复"确认"或"yes"）
3. 再执行恢复脚本

**警告模板：**
```
⚠️ 警告：恢复操作有严重风险！

备份中的敏感信息已脱敏（Token 等变成 <REDACTED>）
直接恢复会导致 OpenClaw 无法启动！

恢复后你需要：
1. 手动编辑 openclaw.json
2. 填写正确的 Token、API Key 等敏感信息

是否确认恢复？请回复"确认"
```

**只有用户明确回复"确认"后，才能执行：**

```bash
# 恢复所有配置
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/restore.sh --all

# 只恢复 workspace
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/restore.sh --workspace

# 只恢复 openclaw.json
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/restore.sh --config
```

### 回滚到指定版本

**⚠️ AI 执行前必须确认：**

当用户要求回滚时，AI 必须：
1. 先警告用户风险（同恢复操作）
2. 等待用户明确确认
3. 再执行回滚脚本

**警告模板：**
```
⚠️ 警告：回滚操作有严重风险！

回滚的版本中敏感信息已脱敏（Token 等变成 <REDACTED>）
回滚后会导致 OpenClaw 无法启动！

回滚后你需要：
1. 手动编辑 openclaw.json
2. 填写正确的 Token、API Key 等敏感信息

是否确认回滚？请回复"确认"
```

**只有用户明确回复"确认"后，才能执行：**

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/rollback.sh <commit-hash>
```

## 重要提示

1. **修改核心配置前先备份**
   - 用户要求修改 openclaw.json 时，先执行 backup.sh
   
2. **Gateway 启动失败时**
   - 如果配置错误导致 Gateway 无法启动，你可能也会宕机
   - 此时用户需要直接运行 restore.sh 恢复配置
   - 脚本独立运行，不依赖 OpenClaw 服务

3. **脚本路径**
   - 所有脚本在 `~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/`
   - 配置文件在 `~/.openclaw-backup/`
   - 备份数据在用户指定的 Git 仓库

4. **多系统支持**
   - Linux/macOS 原生支持
   - Windows 需要 Git Bash 或 WSL

## 错误处理

### SSH 推送失败
- 检查 SSH key 配置
- 检查 Git insteadOf 规则冲突
- 脚本会自动处理 insteadOf 冲突

### 网络问题
- 脚本会重试 3 次
- 失败后本地仍有备份

### 恢复前安全
- 恢复前会自动创建当前配置的备份
- 可以回滚恢复操作

## 配置文件

### ~/.openclaw-backup/config.json

```json
{
  "repository": "git@github.com:username/openclaw-backup.git",
  "branch": "main",
  "backup_items": {
    "openclaw_config": { "enabled": true },
    "workspace": { "enabled": true },
    "claude_code": { "enabled": false },
    "codex": { "enabled": false },
    "systemd": { "enabled": true }
  }
}
```

### ~/.openclaw-backup/desensitize.json

定义脱敏规则，支持正则表达式匹配。

## 使用场景示例

**场景 1：用户要修改配置**
```
用户: "帮我在 openclaw.json 里添加一个新的 Telegram 账户"
你: 先执行备份...
    bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/backup.sh
    然后修改配置
```

**场景 2：查看备份历史**
```
用户: "我想看看之前的备份版本"
你: bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/history.sh
```
