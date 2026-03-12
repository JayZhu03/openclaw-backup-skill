# OpenClaw Backup Skill

## 触发条件

当用户提到以下关键词时使用此 skill：
- "备份配置"、"backup"、"创建备份"、"初始化备份"
- "恢复配置"、"restore"、"回滚"
- "查看备份历史"、"backup history"
- 修改 openclaw.json 等核心配置前

## AI 引导式配置（推荐）

当用户说"初始化 openclaw-backup" 或 "配置备份"时，使用以下流程：

### 步骤 1: 收集信息

询问用户以下问题：

1. **GitHub 仓库地址？**
   - 格式：`git@github.com:username/repo.git`（SSH）或 `https://github.com/username/repo.git`（HTTPS）
   - 建议使用 SSH 格式

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

### 执行备份

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/backup.sh
```

自动完成：
- 脱敏敏感信息
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

```bash
# 恢复所有配置
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/restore.sh --all

# 只恢复 workspace
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/restore.sh --workspace

# 只恢复 openclaw.json
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/restore.sh --config
```

### 回滚到指定版本

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
