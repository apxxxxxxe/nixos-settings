# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS system configuration repository that defines a complete declarative system setup for a development workstation. The configuration includes desktop environment (i3/awesome WM), Japanese localization, advanced audio processing with noise cancellation, and extensive development tools.

## Common Development Commands

### System Management
```bash
# Apply configuration changes
sudo nixos-rebuild switch

# Test configuration without making it permanent  
sudo nixos-rebuild test

# Build configuration without applying
sudo nixos-rebuild build

# Preview changes without building
sudo nixos-rebuild dry-build

# Rollback to previous generation
sudo nixos-rebuild --rollback switch
```

### Package Management
```bash
# Search for packages
nix search nixpkgs packagename

# Update channel (if not using flakes)
sudo nix-channel --update
```

## Architecture and Structure

### Core Configuration Files
- **`configuration.nix`**: Main system configuration with user setup, desktop environment, packages, and services
- **`hardware-configuration.nix`**: Auto-generated hardware-specific settings (boot, filesystems, drivers)
- **`install.sh`**: Installation script that replaces `/etc/nixos` with repository content

### Modular Components
- **`modules/rnnoise.nix`**: Custom audio processing module implementing RNNoise-based microphone noise cancellation with PipeWire filter chains
- **`pkgs/`**: Custom package definitions including:
  - `breeze-cursor-theme.nix`: BreezeX cursor theme
  - `mise/default.nix`: Development environment manager (version 2024.2.5)
  - `tmux-sixel/default.nix`: Enhanced tmux with sixel image support

## Configuration Patterns

### NixOS Conventions Used
- User variables defined with let bindings at configuration top (`user1 = "applepie"`)
- Packages organized by functional categories (essential, development, desktop, entertainment)
- Custom modules imported via `imports = [ ./modules/rnnoise.nix ]`
- Version pinning for stability (system.stateVersion = "25.05")
- Explicit unfree package allowance enabled

### Development Environment
- **Languages**: Go, Deno, Rust (via rustup), with mise for environment management
- **Editors**: Neovim, Vim with extensive plugin ecosystem
- **Terminal**: WezTerm as primary terminal
- **Shell Tools**: fzf, ripgrep, ghq, lazygit, gh CLI
- **Japanese Input**: fcitx5 with SKK and Mozc input methods

### Audio System Architecture
- PipeWire-based audio with advanced noise cancellation
- Custom filter chains for CM106 audio device
- RNNoise integration for real-time microphone processing
- Complex routing defined in separate rnnoise.nix module

## System Characteristics

### Hardware Configuration
- AMD CPU with NVME storage
- systemd-boot bootloader
- Network interface auto-configured
- Asia/Tokyo timezone with Japanese locale

### Desktop Environment
- Window managers: i3 and awesome (awesome as default)  
- LightDM display manager
- Applications: Firefox, Discord, Steam, Spotify, AzPainter, Anki
- Cursor theme: Custom BreezeX implementation

## Development Workflow

1. Edit configuration files (mainly `configuration.nix`)
2. Test changes with `sudo nixos-rebuild test`
3. Apply with `sudo nixos-rebuild switch` when satisfied
4. Commit changes to git with simple messages ("periodic commit" pattern observed)
5. Push to remote repository

## Important Notes

- This system uses bilingual comments (English/Japanese)
- Experimental Nix features (flakes, nix-command) are enabled
- Firewall is enabled with ping allowed
- System includes gaming setup (Steam) and creative tools
- Custom packages follow proper Nix expression patterns with full metadata