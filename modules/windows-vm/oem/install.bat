@echo off
REM Windows VM Auto-Setup Script
REM This script runs automatically during Windows installation

echo ========================================
echo Running Windows VM Auto-Setup...
echo ========================================

REM Run PowerShell setup script (full provisioning)
powershell -ExecutionPolicy Bypass -File "C:\OEM\setup.ps1"

echo ========================================
echo Auto-Setup Complete!
echo ========================================
