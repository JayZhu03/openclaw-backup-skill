# 故障排除

## 常见问题

### 1. SSH 推送失败

**错误：**
```
fatal: could not read Username for 'https://github.com'
```

**原因：** Git insteadOf 规则冲突

**解决：**
```bash
# 临时移除规则
git config --global --unset-all url.https://github.com/.insteadOf

# 推送
git push

# 恢复规则
git config --global --add url.https://github.com/.insteadOf "git@github.com:"
```

### 2. 嵌套 Git 仓库错误

**错误：**
```
warning: adding embedded git repository
fatal: adding files failed
```

**原因：** Claude Code 插件缓存包含 .git 目录

**解决：** 已自动排除 .git 目录（v1.2.1+）

### 3. 恢复后 OpenClaw 无法启动

**错误：** HTTP 401 invalid access token

**原因：** Token 被脱敏为 `<REDACTED>`

**解决：**
1. 编辑 `~/.openclaw/openclaw.json`
2. 手动填写正确的 Token
3. 重启 Gateway

### 4. 备份仓库不存在

**错误：** 备份仓库不存在

**解决：**
```bash
# 重新初始化
bash ~/.openclaw/workspace/skills/openclaw-backup-skill/scripts/unix/init.sh
```

## 日志查看

### Git 日志
```bash
cd ~/openclaw-backup
git log --oneline
```

### 检查配置
```bash
cat ~/.openclaw-backup/config.json
```
