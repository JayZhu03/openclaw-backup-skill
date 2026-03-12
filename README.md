# OpenClaw Backup Skill

自动备份 OpenClaw 配置到 GitHub 私有仓库，支持版本管理和一键恢复。

## 功能特性

- ✅ 自动脱敏敏感信息（Token、API Key、密钥等）
- ✅ 支持多系统（Linux / macOS / Windows）
- ✅ 版本管理（查看历史、回滚到任意版本）
- ✅ 灵活配置（可选备份项）
- ✅ 定时自动备份（可选 cron）

## 系统要求

### Linux / macOS
- Bash 4.0+
- Git 2.0+
- 已配置 GitHub SSH key

### Windows
- Git Bash（推荐）或 WSL
- Git 2.0+
- 已配置 GitHub SSH key

## 快速开始

### 1. 安装

```bash
# 通过 skillhub（国内优化）
skillhub install openclaw-backup

# 或通过 clawhub
clawhub install openclaw-backup
```

### 2. 初始化

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/init.sh
```

按照交互式向导完成配置。

### 3. 备份

```bash
# 手动备份
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/backup.sh

# 查看状态
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/status.sh
```

### 4. 恢复

```bash
# 查看历史版本
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/history.sh

# 恢复到最新备份
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/restore.sh --all

# 回滚到指定版本
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/rollback.sh <commit-hash>
```

## 备份内容

### 默认备份
- ✅ OpenClaw 主配置 (`~/.openclaw/openclaw.json`)
- ✅ Workspace 工作空间 (`~/.openclaw/workspace/`)

### 可选备份（按需启用）
- ⬜ Claude Code 配置 (`~/.claude/`)
- ⬜ Codex 配置 (`~/.codex/`)
- ⬜ systemd 服务文件（仅 Linux）

编辑 `~/.openclaw-backup/config.json` 启用可选项。

## 配置文件

配置文件位于 `~/.openclaw-backup/`：

- `config.json` - 备份配置（仓库地址、备份项等）
- `desensitize.json` - 脱敏规则（可自定义）

## 常见问题

### Q: Windows 用户如何使用？
A: 必须使用 Git Bash 或 WSL，路径使用 Unix 风格。

### Q: 如何配置自动备份？
A: 运行 `init.sh` 时选择配置 cron，或手动添加到 crontab。

### Q: 备份失败怎么办？
A: 检查 SSH key 配置、网络连接、Git 仓库权限。

### Q: 如何自定义脱敏规则？
A: 编辑 `~/.openclaw-backup/desensitize.json`。

## 开源协议

MIT License - 详见 [LICENSE](LICENSE)

## 贡献

欢迎提交 Issue 和 Pull Request！

## 作者

JayZhu03
