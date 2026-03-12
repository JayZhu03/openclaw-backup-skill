# OpenClaw Backup Skill

> ⚠️ **重要警告** ⚠️  
> **恢复操作会覆盖当前配置！备份中的敏感信息已脱敏（Token 等变成 `<REDACTED>`），直接恢复会导致 OpenClaw 无法启动！**  
> 
> **恢复前请务必：**
> 1. 确认你有原始的 Token 等敏感信息
> 2. 恢复后立即手动填写 Token 等敏感信息到 `~/.openclaw/openclaw.json`
> 
> **如果恢复后出问题：**
> - 脚本会自动创建安全备份到 `~/.openclaw-backup-safety-时间戳/`
> - 恢复方法：`cp -r ~/.openclaw-backup-safety-*/openclaw.json ~/.openclaw/`
> - 或完整恢复：`cp -r ~/.openclaw-backup-safety-*/* ~/.openclaw/`

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.2.1-blue.svg)](https://github.com/JayZhu03/openclaw-backup-skill)

自动备份 OpenClaw 配置到 GitHub 私有仓库，支持版本管理和一键恢复。

## ✨ 功能特性

- 🔒 **自动脱敏** - 敏感信息（Token、API Key）自动脱敏
- 🌍 **跨平台支持** - Linux、macOS、Windows 原生支持
- 📦 **版本管理** - 完整的 Git 历史记录，支持回滚到任意版本
- ⚙️ **灵活配置** - 可选备份项，按需启用
- 🤖 **AI 引导** - 聊天式配置，无需手动编辑
- ⏰ **定时备份** - 可选 cron 自动备份（Linux/macOS）

## 📋 系统要求

### Linux / macOS
- Bash 4.0+
- Git 2.0+
- rsync
- 已配置 GitHub SSH key

### Windows
- PowerShell 5.0+（Windows 10+ 自带）
- Git 2.0+
- 已配置 GitHub SSH key

## 🚀 快速开始

### 1. 安装

**方式 1：通过 OpenClaw AI 安装（推荐）**

```
请安装 https://github.com/JayZhu03/openclaw-backup-skill 这个 skill
```

**方式 2：手动克隆**

```bash
git clone https://github.com/JayZhu03/openclaw-backup-skill.git ~/.openclaw/workspace/skills/openclaw-backup-skill
```

### 2. 初始化

**方式 1：AI 引导配置（推荐）**

对 OpenClaw 说：
```
帮我初始化 openclaw-backup，
仓库地址是 git@github.com:你的用户名/仓库名.git，
不需要备份 Claude Code 和 Codex，
不需要定时任务
```

**方式 2：交互式向导**

```bash
# Linux/macOS
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/unix/init.sh

# Windows
powershell ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/windows/init.ps1
```

**方式 3：命令行参数**

```bash
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/unix/init.sh \
  --repo "git@github.com:username/repo.git" \
  --claude-code yes \
  --codex yes \
  --non-interactive
```

### 3. 使用

**通过 AI 对话（推荐）**

直接对 OpenClaw 说：
- "备份" 或 "执行备份" - 普通备份
- "更新前备份一下" - 带描述的备份（历史中显示"更新前的备份"）
- "测试前先备份" - 带描述的备份（历史中显示"测试前的备份"）
- "备份状态" 或 "查看备份状态" - 查看状态
- "备份历史" - 查看历史记录（包含自定义描述）
- "恢复配置" - 恢复（会先警告风险）

**通过命令行**

**执行备份**
```bash
# 普通备份
~/.openclaw/workspace/skills/openclaw-backup-skill/backup

# 带自定义描述的备份
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/unix/backup.sh --message "更新前的备份"
```

**查看状态**
```bash
~/.openclaw/workspace/skills/openclaw-backup-skill/status
```

**查看历史**
```bash
~/.openclaw/workspace/skills/openclaw-backup-skill/history
```

**恢复配置**
```bash
~/.openclaw/workspace/skills/openclaw-backup-skill/restore
```

## 📦 备份内容

### 默认备份（必选）
- ✅ OpenClaw 主配置 (`~/.openclaw/openclaw.json`)
- ✅ Workspace 工作空间 (`~/.openclaw/workspace/`)

### 可选备份
- ⬜ Claude Code 配置 (`~/.claude/`)
- ⬜ Codex 配置 (`~/.codex/`)
- ⬜ systemd 服务文件（仅 Linux）

编辑 `~/.openclaw-backup/config.json` 启用可选项。

## ⚙️ 配置文件

配置文件位于 `~/.openclaw-backup/`：

- **config.json** - 备份配置（仓库地址、备份项等）
- **desensitize.json** - 脱敏规则（可自定义）

### 示例配置

```json
{
  "repository": "git@github.com:username/openclaw-backup.git",  // GitHub 仓库地址（SSH 格式推荐）
  "branch": "main",  // Git 分支名称
  "backup_items": {
    "openclaw_config": {
      "enabled": true,  // 是否备份 OpenClaw 主配置（必选）
      "path": "~/.openclaw/openclaw.json",  // 配置文件路径
      "required": true  // 是否为必需项
    },
    "workspace": {
      "enabled": true,  // 是否备份 Workspace 工作空间（必选）
      "path": "~/.openclaw/workspace/",  // Workspace 路径
      "required": true,  // 是否为必需项
      "exclude": ["node_modules", "*.log", ".DS_Store", "skills"]  // 排除的文件/目录
    },
    "claude_code": {
      "enabled": false,  // 是否备份 Claude Code 配置（可选）
      "path": "~/.claude/",  // Claude Code 配置路径
      "required": false  // 是否为必需项
    },
    "codex": {
      "enabled": false,  // 是否备份 Codex 配置（可选）
      "path": "~/.codex/",  // Codex 配置路径
      "required": false  // 是否为必需项
    },
    "systemd": {
      "enabled": false,  // 是否备份 systemd 服务文件（可选，仅 Linux）
      "path": "~/.config/systemd/user/openclaw-*.service",  // systemd 服务文件路径
      "required": false  // 是否为必需项
    }
  },
  "desensitize": {
    "enabled": true,  // 是否启用脱敏（强烈推荐）
    "rules_file": "~/.openclaw-backup/desensitize.json"  // 脱敏规则文件路径
  },
  "git": {
    "auto_commit": true,  // 是否自动提交到 Git
    "auto_push": true  // 是否自动推送到 GitHub
  }
}
```

## 🔧 常见问题

### Q: Windows 用户如何使用？
A: Windows 用户使用 PowerShell 脚本，无需 WSL：
- 直接运行：`powershell scripts\windows\backup.ps1`
- 或使用包装脚本：`.\backup`（自动选择）
- 需要 PowerShell 5.0+（Windows 10+ 自带）

### Q: 如果安装路径不是默认路径怎么办？
A: 脚本会自动检测常见路径，如果检测失败：
1. 手动编辑 `~/.openclaw-backup/config.json`
2. 修改对应项的 `path` 字段为实际路径

### Q: 如何配置自动备份？
A: Linux/macOS 用户可以配置 cron：
```bash
# 每天凌晨 2:00 自动备份
0 2 * * * bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/unix/backup.sh
```

### Q: 备份失败怎么办？
A: 检查以下项目：
- SSH key 是否配置正确
- 网络连接是否正常
- Git 仓库权限是否正确
- 是否有嵌套的 Git 仓库（已自动排除）

### Q: 如何自定义脱敏规则？
A: 编辑 `~/.openclaw-backup/desensitize.json`，添加自定义规则。

## 🛡️ 安全建议

- ⚠️ **必须使用私有仓库** - 备份包含敏感信息
- 🔑 **使用 SSH 密钥** - 避免在配置中存储密码
- 🔒 **定期检查脱敏规则** - 确保敏感信息被正确处理
- 📝 **审查备份内容** - 首次备份后检查 GitHub 仓库

## 📄 开源协议

MIT License - 详见 [LICENSE](LICENSE)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 👤 作者

[JayZhu03](https://github.com/JayZhu03)

## 🔗 相关链接

- [GitHub 仓库](https://github.com/JayZhu03/openclaw-backup-skill)
- [问题反馈](https://github.com/JayZhu03/openclaw-backup-skill/issues)
- [更新日志](CHANGELOG.md)
