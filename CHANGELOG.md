# Changelog

All notable changes to this project will be documented in this file.

## [1.3.0] - 2026-03-12

### Added
- 自定义备份描述功能
- 支持 `--message` 参数添加备份说明
- AI 自动识别用户意图并添加描述（如"更新前备份"）
- 历史记录显示自定义描述
- 添加 frontmatter 元数据到 SKILL.md
- 添加 references/ 目录（安全最佳实践、故障排除）

### Changed
- 优化 README 文档结构
- 添加安全备份恢复详细说明
- 精简 SKILL.md，移除冗余章节
- 更新初始化示例（推荐最小化备份）

### Fixed
- 修复 rollback 缺少警告的问题
- 添加 rollback 的 AI 确认机制

## [1.2.2] - 2026-03-12

### Fixed
- **严重问题修复**：添加恢复操作警告，防止用户恢复脱敏配置导致 OpenClaw 宕机
- restore.sh 和 restore.ps1 添加确认提示
- README 和 SKILL.md 添加醒目警告

### Changed
- 恢复操作现在需要用户明确确认（输入 yes）

## [1.2.1] - 2026-03-12

### Fixed
- Windows 版本排除 `.git` 目录，避免嵌套 Git 仓库冲突
- 修复 Claude Code 插件缓存导致的备份失败问题
- 使用 robocopy 优化 Windows 文件复制性能

## [1.2.0] - 2026-03-12

### Added
- **Windows 原生支持**（PowerShell 脚本）
- 自动检测操作系统并选择对应脚本
- 统一的包装脚本（backup/init/status/history/restore/rollback）
- Windows 路径自动处理（`C:\Users\...`）

### Changed
- 重构脚本目录结构：`scripts/unix/` 和 `scripts/windows/`
- 更新文档说明 Windows 使用方式

## [1.1.0] - 2026-03-12

### Added
- AI 引导式配置（适合聊天软件用户）
- 路径自动检测（OpenClaw/Claude Code/Codex）
- 非交互式模式（支持命令行参数）
- SSH 密钥验证
- 仓库可见性检查（警告公开仓库）
- 三种初始化方式（AI 引导/交互式/命令行）

### Fixed
- JSON 解析问题（使用 Python + grep 回退）
- Git insteadOf 规则冲突处理
- 仓库可见性检查逻辑（正确处理 404）

### Changed
- 优化 SKILL.md 文档
- 更新 README.md 添加三种初始化方式说明
- 改进错误处理和用户反馈

## [1.0.0] - 2026-03-12

### Added
- 初始版本发布
- 自动备份 OpenClaw 配置到 GitHub
- 敏感信息脱敏功能
- 多系统支持（Linux / macOS / Windows）
- 版本管理和回滚功能
- 可选备份项配置
- 交互式初始化向导
- 自动备份（cron）支持

### Features
- `init.sh` - 初始化配置
- `backup.sh` - 执行备份
- `restore.sh` - 恢复配置
- `history.sh` - 查看历史
- `rollback.sh` - 回滚版本
- `status.sh` - 查看状态
