# OpenClaw Backup Rollback Script for Windows
# PowerShell version

param(
    [Parameter(Mandatory=$true)]
    [string]$CommitHash
)

$ErrorActionPreference = "Stop"
$BACKUP_DIR = "$env:USERPROFILE\openclaw-backup"

function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Failure { Write-Host "❌ $args" -ForegroundColor Red }
function Write-Warning { Write-Host "⚠️  $args" -ForegroundColor Yellow }

if (-not (Test-Path "$BACKUP_DIR\.git")) {
    Write-Failure "备份仓库不存在"
    exit 1
}

# 严重警告
Write-Host ""
Write-Warning "警告：回滚操作有风险！"
Write-Host ""
Write-Host "备份中的敏感信息已脱敏（Token 等变成 <REDACTED>）" -ForegroundColor Yellow
Write-Host "回滚后会导致 OpenClaw 无法启动！" -ForegroundColor Yellow
Write-Host ""
Write-Host "回滚后你需要："
Write-Host "  1. 手动编辑 openclaw.json"
Write-Host "  2. 填写正确的 Token、API Key 等敏感信息"
Write-Host ""
Write-Host "是否继续？(yes/no)" -ForegroundColor Red
$confirm = Read-Host

if ($confirm -ne "yes") {
    Write-Host "已取消回滚"
    exit 0
}

Write-Host "⏪ 回滚到版本: $CommitHash"

Set-Location $BACKUP_DIR
git checkout $CommitHash

Write-Success "回滚完成！"
Write-Host "现在可以运行 restore.ps1 恢复配置"