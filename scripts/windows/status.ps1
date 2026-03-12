# OpenClaw Backup Status Script for Windows
# PowerShell version

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$CONFIG_DIR = "$env:USERPROFILE\.openclaw-backup"
$CONFIG_FILE = "$CONFIG_DIR\config.json"
$BACKUP_DIR = "$env:USERPROFILE\openclaw-backup"

function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Failure { Write-Host "❌ $args" -ForegroundColor Red }

Write-Host "📊 OpenClaw Backup 状态"
Write-Host ""

# Check config
if (Test-Path $CONFIG_FILE) {
    Write-Success "配置文件: $CONFIG_FILE"
    $config = Get-Content $CONFIG_FILE | ConvertFrom-Json
    Write-Host "   仓库: $($config.repository)"
} else {
    Write-Failure "配置文件不存在"
    exit 1
}

Write-Host ""

# Check backup repo
if (Test-Path "$BACKUP_DIR\.git") {
    Write-Success "备份仓库: $BACKUP_DIR"
    Set-Location $BACKUP_DIR
    $lastCommit = git log -1 --format="%h - %s (%ar)"
    Write-Host "   最后备份: $lastCommit"
} else {
    Write-Failure "备份仓库不存在"
}