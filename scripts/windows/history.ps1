# OpenClaw Backup History Script for Windows
# PowerShell version

$BACKUP_DIR = "$env:USERPROFILE\openclaw-backup"

if (-not (Test-Path "$BACKUP_DIR\.git")) {
    Write-Host "❌ 备份仓库不存在" -ForegroundColor Red
    exit 1
}

Write-Host "📜 备份历史："
Set-Location $BACKUP_DIR
git log --oneline --decorate