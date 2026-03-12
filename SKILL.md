# OpenClaw Backup Skill

## 触发条件

当用户提到以下关键词时使用此 skill：
- "备份配置"、"backup"、"创建备份"
- "恢复配置"、"restore"、"回滚"
- "查看备份历史"、"backup history"
- 修改 openclaw.json 等核心配置前

## 使用方法

### 初始化（首次使用）

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/init.sh
```

引导用户完成：
1. GitHub 仓库配置
2. SSH key 验证
3. 可选备份项选择
4. 自动备份设置（可选）

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

**场景 2：配置炸了需要恢复**
```
用户: "Gateway 启动失败了，帮我恢复配置"
你: 执行恢复...
    bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/restore.sh --all
```

**场景 3：查看备份历史**
```
用户: "我想看看之前的备份版本"
你: bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/history.sh
```
