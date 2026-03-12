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

**方式 1：通过 OpenClaw AI 安装（推荐）**

对 OpenClaw 说：
```
请安装 https://github.com/JayZhu03/openclaw-backup-skill 这个 skill
```

**方式 2：手动克隆**

```bash
git clone https://github.com/JayZhu03/openclaw-backup-skill.git ~/.openclaw/workspace/skills/openclaw-backup-skill
```

### 2. 初始化

有三种初始化方式，选择最适合你的：

**方式 1：AI 引导配置（推荐，适合聊天软件用户）**

对 OpenClaw 说：
```
帮我初始化 openclaw-backup，
仓库地址是 git@github.com:你的用户名/仓库名.git，
需要备份 Claude Code 和 Codex
```

AI 会自动生成配置文件，无需手动操作。

**方式 2：交互式向导（适合终端用户）**

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/init.sh
```

按照提示输入配置信息。

**方式 3：命令行参数（适合脚本调用）**

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/init.sh \
  --repo "git@github.com:username/repo.git" \
  --claude-code yes \
  --codex yes \
  --auto-backup no \
  --non-interactive
```

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
A: 必须使用 Git Bash 或 WSL。在 Git Bash 中：
- 路径使用 Unix 风格（`/c/Users/...` 而不是 `C:\Users\...`）
- 运行脚本：`bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/backup.sh`
- 注意：Windows 环境未经充分测试，可能存在兼容性问题

### Q: 如果 OpenClaw/Claude Code/Codex 安装路径不是默认路径怎么办？
A: 脚本会自动检测常见路径，如果检测失败：
1. 手动编辑 `~/.openclaw-backup/config.json`
2. 修改对应项的 `path` 字段为实际路径
3. 例如：`"path": "/custom/path/to/openclaw.json"`

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
