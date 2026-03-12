# 安全最佳实践

## 敏感信息保护

### 自动脱敏
备份会自动脱敏以下信息：
- `"token": "xxx"` → `"token": "<REDACTED>"`
- `"apiKey": "xxx"` → `"apiKey": "<REDACTED>"`

### 自定义脱敏规则
编辑 `~/.openclaw-backup/desensitize.json` 添加规则：
```json
{
  "patterns": [
    {
      "regex": "\"password\":\\s*\"[^\"]*\"",
      "replacement": "\"password\": \"<REDACTED>\""
    }
  ]
}
```

## 仓库安全

### 必须使用私有仓库
- ⚠️ 公开仓库会暴露配置结构
- ⚠️ 即使脱敏也可能有遗漏
- ✅ 使用 GitHub 私有仓库

### SSH 密钥配置
```bash
# 生成 SSH 密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 添加到 GitHub
cat ~/.ssh/id_ed25519.pub
# 复制到 https://github.com/settings/keys
```

## 恢复安全

### 安全备份机制
恢复前自动创建安全备份：
- 位置：`~/.openclaw-backup-safety-时间戳/`
- 内容：恢复前的完整配置
- 保留时间：手动清理

### 恢复后检查清单
1. ✅ 检查 Token 是否正确填写
2. ✅ 测试 OpenClaw 是否能启动
3. ✅ 验证 Gateway 连接
4. ✅ 检查关键功能是否正常
