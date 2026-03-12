# OpenClaw Backup Script for Windows
# PowerShell version

$ErrorActionPreference = "Stop"

$CONFIG_DIR = "$env:USERPROFILE\.openclaw-backup"
$CONFIG_FILE = "$CONFIG_DIR\config.json"
$BACKUP_DIR = "$env:USERPROFILE\openclaw-backup"

# Colors
function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Error { Write-Host "❌ $args" -ForegroundColor Red }
function Write-Info { Write-Host "  → $args" -ForegroundColor Cyan }

# Check if config exists
if (-not (Test-Path $CONFIG_FILE)) {
    Write-Error "配置文件不存在: $CONFIG_FILE"
    Write-Host "请先运行 init.ps1 初始化配置"
    exit 1
}

# Read config
$config = Get-Content $CONFIG_FILE | ConvertFrom-Json
$REPO = $config.repository
$BRANCH = $config.branch

Write-Host "📦 开始备份 OpenClaw 配置..."
Write-Info "仓库: $REPO"
Write-Info "分支: $BRANCH"

# Initialize or update backup repo
if (-not (Test-Path "$BACKUP_DIR\.git")) {
    Write-Info "初始化备份仓库..."
    if (Test-Path $BACKUP_DIR) { Remove-Item -Recurse -Force $BACKUP_DIR }
    git init $BACKUP_DIR
    Set-Location $BACKUP_DIR
    git remote add origin $REPO
} else {
    Set-Location $BACKUP_DIR
    git fetch origin
}

# Clean backup directories
Remove-Item -Recurse -Force "$BACKUP_DIR\workspace-files" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$BACKUP_DIR\config-files" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path "$BACKUP_DIR\workspace-files" | Out-Null
New-Item -ItemType Directory -Force -Path "$BACKUP_DIR\config-files" | Out-Null

# Backup OpenClaw config
if ($config.backup_items.openclaw_config.enabled) {
    Write-Info "脱敏 openclaw.json..."
    $openclawConfig = "$env:USERPROFILE\.openclaw\openclaw.json"
    if (Test-Path $openclawConfig) {
        $content = Get-Content $openclawConfig -Raw
        # Simple desensitization
        $content = $content -replace '"token":\s*"[^"]*"', '"token": "<REDACTED>"'
        $content = $content -replace '"apiKey":\s*"[^"]*"', '"apiKey": "<REDACTED>"'
        $content | Set-Content "$BACKUP_DIR\config-files\openclaw.json"
    }
}

# Backup workspace
if ($config.backup_items.workspace.enabled) {
    Write-Info "备份 workspace..."
    $workspacePath = "$env:USERPROFILE\.openclaw\workspace"
    if (Test-Path $workspacePath) {
        Copy-Item -Recurse -Force "$workspacePath\*" "$BACKUP_DIR\workspace-files\" -Exclude @("node_modules", "*.log", ".DS_Store", "skills")
    }
}

# Backup Claude Code
if ($config.backup_items.claude_code.enabled) {
    Write-Info "备份 Claude Code 配置..."
    $claudePath = "$env:USERPROFILE\.claude"
    if (Test-Path $claudePath) {
        Copy-Item -Recurse -Force $claudePath "$BACKUP_DIR\config-files\claude\"
    }
}

# Backup Codex
if ($config.backup_items.codex.enabled) {
    Write-Info "备份 Codex 配置..."
    $codexPath = "$env:USERPROFILE\.codex"
    if (Test-Path $codexPath) {
        Copy-Item -Recurse -Force $codexPath "$BACKUP_DIR\config-files\codex\"
    }
}

# Commit and push
Write-Info "提交到 Git..."
git add -A
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Backup $timestamp"

Write-Info "推送到 GitHub..."
git push -u origin $BRANCH

Write-Success "备份完成！"
