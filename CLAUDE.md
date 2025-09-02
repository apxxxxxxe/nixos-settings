# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS system configuration repository that defines a complete declarative system setup for a development workstation. The configuration includes desktop environment (i3/awesome WM), Japanese localization, advanced audio processing with noise cancellation, and extensive development tools.

## Common Development Commands

### System Management (Flakes)
```bash
# Apply configuration changes (flakes)
sudo nixos-rebuild switch --flake .#nixos

# Test configuration without making it permanent (flakes)
sudo nixos-rebuild test --flake .#nixos

# Build configuration without applying (flakes)
sudo nixos-rebuild build --flake .#nixos

# Preview changes without building (flakes)
sudo nixos-rebuild dry-build --flake .#nixos

# Rollback to previous generation
sudo nixos-rebuild --rollback switch

# Update flake inputs
nix flake update

# Using SUDO_ASKPASS for password prompts (useful for scripts/automation)
SUDO_ASKPASS=/home/applepie/.local/bin/askpass sudo nixos-rebuild switch --flake .#nixos
```

### Home Manager Commands
```bash
# Apply Home Manager configuration (integrated with NixOS rebuild)
# Home Manager changes apply automatically with nixos-rebuild

# Switch Home Manager configuration independently
home-manager switch --flake .#applepie

# Check Home Manager generations
home-manager generations
```

### Legacy Commands (without flakes)
```bash
# Apply configuration changes (legacy)
sudo nixos-rebuild switch

# Test configuration (legacy)
sudo nixos-rebuild test
```

### Package Management
```bash
# Search for packages
nix search nixpkgs packagename

# Update flake inputs
nix flake update

# Show flake info
nix flake show
```

## Architecture and Structure

### Core Configuration Files
- **`flake.nix`**: Flakes configuration defining inputs (nixpkgs, neovim-flake, home-manager) and system output
- **`configuration.nix`**: Main system configuration with user setup, desktop environment, packages, and services
- **`home.nix`**: Home Manager configuration for user-specific settings and XDG directories
- **`xdg-config.nix`**: XDG configuration module for user directory setup
- **`hardware-configuration.nix`**: Auto-generated hardware-specific settings (boot, filesystems, drivers)
- **`install.sh`**: Installation script that replaces `/etc/nixos` with repository content

### Modular Components
- **`modules/rnnoise.nix`**: Custom audio processing module implementing RNNoise-based microphone noise cancellation with PipeWire filter chains
- **`pkgs/`**: Custom package definitions including:
  - `breeze-cursor-theme.nix`: BreezeX cursor theme
  - `xrdp.nix`: Custom XRDP service module for remote desktop access
  - `tmux-sixel/default.nix`: Enhanced tmux with sixel image support
- **`flakes/neovim/`**: Separate Neovim configuration as a flake with overlay integration

## Configuration Patterns

### NixOS Conventions Used
- **Flakes Architecture**: Uses experimental flakes feature with nixpkgs-unstable input and Home Manager integration
- User variables defined with let bindings at configuration top (`user1 = "applepie"`)  
- Packages organized by functional categories (essential, development, desktop, entertainment)
- Custom modules imported via `imports = [ ./modules/rnnoise.nix ./pkgs/xrdp.nix ]`
- Module overlays for custom packages (Neovim flake overlay)
- Home Manager integrated as NixOS module for user-specific configurations
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
- GRUB bootloader with OS prober enabled (/dev/sda)
- Network interface auto-configured via NetworkManager
- Asia/Tokyo timezone with Japanese locale
- Xbox controller support (xpadneo)
- Bluetooth enabled with experimental features

### Desktop Environment
- Window managers: i3 and awesome (awesome as default)  
- LightDM display manager with XRDP remote desktop support
- Applications: Firefox, Discord, Steam, Spotify, AzPainter, Anki
- Cursor theme: Custom BreezeX implementation
- Wine/PlayOnLinux for Windows compatibility

## Development Workflow

1. Edit configuration files (mainly `configuration.nix` or flake inputs)
2. Test changes with `sudo nixos-rebuild test --flake .#nixos`
3. Apply with `sudo nixos-rebuild switch --flake .#nixos` when satisfied
4. Update flake inputs when needed with `nix flake update`
5. Commit changes to git with simple messages ("periodic commit" pattern observed)
6. Push to remote repository

## Important Notes

- **Flakes-based system**: Uses experimental flakes features for reproducible builds
- This system uses bilingual comments (English/Japanese)  
- Experimental Nix features (flakes, nix-command) are enabled
- Firewall is enabled with ping allowed, XRDP ports open
- System includes gaming setup (Steam) and creative tools
- Custom packages follow proper Nix expression patterns with full metadata
- GRUB bootloader configured for /dev/sda with OS prober for dual-boot compatibility
- System includes remote desktop access via XRDP service