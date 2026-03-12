# OpenClaw Backup Restore Script for Windows
# PowerShell version

$ErrorActionPreference = "Stop"

$BACKUP_DIR = "$env:USERPROFILE\openclaw-backup"
$SAFETY_BACKUP = "$env:USERPROFILE\.openclaw-backup-safety-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Error { Write-Host "❌ $args" -ForegroundColor Red }
function Write-Warning { Write-Host "⚠️  $args" -ForegroundColor Yellow }
function Write-Info { Write-Host "  → $args" -ForegroundColor Cyan }

if (-not (Test-Path "$BACKUP_DIR\.git")) {
    Write-Error "备份仓库不存在"
    exit 1
}

# 严重警告
Write-Host ""
Write-Warning "警告：恢复操作有风险！"
Write-Host ""
Write-Host "备份中的敏感信息已脱敏（Token 等变成 <REDACTED>）" -ForegroundColor Yellow
Write-Host "直接恢复会导致 OpenClaw 无法启动！" -ForegroundColor Yellow
Write-Host ""
Write-Host "恢复后你需要："
Write-Host "  1. 手动编辑 openclaw.json"
Write-Host "  2. 填写正确的 Token、API Key 等敏感信息"
Write-Host ""
Write-Host "是否继续？(yes/no)" -ForegroundColor Red
$confirm = Read-Host

if ($confirm -ne "yes") {
    Write-Host "已取消恢复"
    exit 0
}

Write-Host "🔄 开始恢复配置..."

# Create safety backup
Write-Info "创建安全备份..."
New-Item -ItemType Directory -Force -Path $SAFETY_BACKUP | Out-Null
if (Test-Path "$env:USERPROFILE\.openclaw") {
    Copy-Item -Recurse -Force "$env:USERPROFILE\.openclaw" "$SAFETY_BACKUP\"
}

# Restore from backup
Set-Location $BACKUP_DIR

Write-Info "恢复 openclaw.json..."
if (Test-Path "$BACKUP_DIR\config-files\openclaw.json") {
    Copy-Item -Force "$BACKUP_DIR\config-files\openclaw.json" "$env:USERPROFILE\.openclaw\openclaw.json"
}

Write-Info "恢复 workspace..."
if (Test-Path "$BACKUP_DIR\workspace-files") {
    Copy-Item -Recurse -Force "$BACKUP_DIR\workspace-files\*" "$env:USERPROFILE\.openclaw\workspace\"
}

Write-Success "恢复完成！"
Write-Host "安全备份位置: $SAFETY_BACKUP"
