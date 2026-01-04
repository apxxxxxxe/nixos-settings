# setup.ps1
# Windows VM 初期セットアップスクリプト
# OEM フェーズで自動実行される

#Requires -RunAsAdministrator

param(
    [string]$ConfigPath = "C:\OEM\winget-config.yaml"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows VM Initial Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# ========================================
# 1. WinGet の準備
# ========================================
Write-Host "`n[1/4] Preparing WinGet..." -ForegroundColor Yellow

$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    Write-Host "WinGet not found. Installing via App Installer..."
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
}

Write-Host "Enabling WinGet configuration feature..."
winget configure --enable

Write-Host "WinGet preparation complete." -ForegroundColor Green

# ========================================
# 2. WinGet Configuration の適用
# ========================================
Write-Host "`n[2/4] Applying WinGet Configuration..." -ForegroundColor Yellow

if (Test-Path $ConfigPath) {
    Write-Host "Validating configuration file..."
    winget configure validate $ConfigPath

    Write-Host "Applying configuration (this may take a while)..."
    winget configure -f $ConfigPath --accept-configuration-agreements --disable-interactivity

    Write-Host "WinGet Configuration applied." -ForegroundColor Green
} else {
    Write-Host "Configuration file not found: $ConfigPath" -ForegroundColor Red
    Write-Host "You can apply it later with:"
    Write-Host "  winget configure -f <path-to-config.yaml> --accept-configuration-agreements"
}

# ========================================
# 3. 追加の設定
# ========================================
Write-Host "`n[3/4] Applying additional settings..." -ForegroundColor Yellow

# Neovim の設定ディレクトリ作成
$nvimConfigDir = "$env:LOCALAPPDATA\nvim"
if (-not (Test-Path $nvimConfigDir)) {
    New-Item -ItemType Directory -Path $nvimConfigDir -Force | Out-Null
    Write-Host "Created Neovim config directory: $nvimConfigDir"
}

Write-Host "Additional settings applied." -ForegroundColor Green

# ========================================
# 4. SSP (伺か) のダウンロードとインストール
# ========================================
Write-Host "`n[4/4] Downloading and installing SSP..." -ForegroundColor Yellow

$sspZipPath = 'C:\Windows\Temp\ssp_full.zip'
$sspDestPath = "$env:USERPROFILE\Desktop\ssp"

try {
    Write-Host "Downloading SSP..."
    cmd /c "curl.exe -L -s --show-error -o `"$sspZipPath`" `"https://ssp.shillest.net/archive/redir.cgi?stable^&full^&zip`""

    if ((Test-Path $sspZipPath) -and (Get-Item $sspZipPath).Length -gt 0) {
        Write-Host "Extracting SSP to $sspDestPath..."
        Expand-Archive -Path $sspZipPath -DestinationPath $sspDestPath -Force
        Remove-Item $sspZipPath -Force -ErrorAction SilentlyContinue
        Write-Host "SSP installation complete." -ForegroundColor Green
    } else {
        throw "Download failed"
    }
} catch {
    Write-Host "Failed to download/install SSP: $_" -ForegroundColor Red
    Write-Host "You can manually download from: https://ssp.shillest.net/"
}

# ========================================
# 完了
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nInstalled packages can be verified with: winget list"
Write-Host ""
