# OpenClaw Backup Init Script for Windows
# PowerShell version

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Stop"

$CONFIG_DIR = "$env:USERPROFILE\.openclaw-backup"
$CONFIG_FILE = "$CONFIG_DIR\config.json"

function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Failure { Write-Host "❌ $args" -ForegroundColor Red }
function Write-Info { Write-Host "  → $args" -ForegroundColor Cyan }

Write-Host "🔧 OpenClaw Backup 初始化向导"
Write-Host ""

# Create config directory
if (-not (Test-Path $CONFIG_DIR)) {
    New-Item -ItemType Directory -Force -Path $CONFIG_DIR | Out-Null
}

# Ask for repository
$repo = Read-Host "GitHub 仓库地址 (例如: git@github.com:username/repo.git)"

# Ask for backup items
Write-Host ""
Write-Host "选择备份项："
$backupClaudeCode = (Read-Host "备份 Claude Code 配置? (y/n)") -eq "y"
$backupCodex = (Read-Host "备份 Codex 配置? (y/n)") -eq "y"

# Create config
$config = @{
    repository = $repo
    branch = "main"
    backup_items = @{
        openclaw_config = @{
            enabled = $true
            path = "$env:USERPROFILE\.openclaw\openclaw.json"
            required = $true
        }
        workspace = @{
            enabled = $true
            path = "$env:USERPROFILE\.openclaw\workspace\"
            required = $true
            exclude = @("node_modules", "*.log", ".DS_Store", "skills")
        }
        claude_code = @{
            enabled = $backupClaudeCode
            path = "$env:USERPROFILE\.claude\"
            required = $false
        }
        codex = @{
            enabled = $backupCodex
            path = "$env:USERPROFILE\.codex\"
            required = $false
        }
    }
    desensitize = @{
        enabled = $true
    }
    git = @{
        auto_commit = $true
        auto_push = $true
    }
}

# Save config
$config | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_FILE

Write-Success "配置完成！"
Write-Host ""
Write-Host "下一步："
Write-Host "  1. 执行首次备份: powershell scripts\windows\backup.ps1"
Write-Host "  2. 查看状态: powershell scripts\windows\status.ps1"