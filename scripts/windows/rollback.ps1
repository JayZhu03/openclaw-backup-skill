# OpenClaw Backup Rollback Script for Windows
# PowerShell version

param(
    [Parameter(Mandatory=$true)]
    [string]$CommitHash
)

$ErrorActionPreference = "Stop"
$BACKUP_DIR = "$env:USERPROFILE\openclaw-backup"

function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Error { Write-Host "❌ $args" -ForegroundColor Red }

if (-not (Test-Path "$BACKUP_DIR\.git")) {
    Write-Error "备份仓库不存在"
    exit 1
}

Write-Host "⏪ 回滚到版本: $CommitHash"

Set-Location $BACKUP_DIR
git checkout $CommitHash

Write-Success "回滚完成！"
Write-Host "现在可以运行 restore.ps1 恢复配置"
