# Desktop Environment Module
# Provides type-safe desktop environment selection
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.desktop;
in {
  imports = [
    ./wm.nix
  ];

  options.services.desktop = {
    type = mkOption {
      type = types.enum [ "wm" "gnome" "kde" ];
      default = "wm";
      description = "Desktop environment type: wm (tiling WMs), gnome, or kde";
    };
  };

  config = {
    # WM 設定は wm.nix で定義、ここで enable を連動
    services.desktopWM.enable = mkDefault (cfg.type == "wm");

    # GNOME 設定
    services.xserver.enable = mkIf (cfg.type == "gnome") true;
    services.displayManager.gdm.enable = mkIf (cfg.type == "gnome") true;
    services.desktopManager.gnome.enable = mkIf (cfg.type == "gnome") true;
    services.gnome.gnome-remote-desktop.enable = mkIf (cfg.type == "gnome") true;

    # KDE 設定
    services.displayManager.sddm = mkIf (cfg.type == "kde") {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = mkIf (cfg.type == "kde") true;

    # DE 固有パッケージ
    environment.systemPackages = mkMerge [
      # GNOME
      (mkIf (cfg.type == "gnome") (with pkgs; [
        gnome-tweaks
      ]))
      # KDE
      (mkIf (cfg.type == "kde") (with pkgs; [
        kdePackages.kate           # テキストエディタ
        kdePackages.konsole        # ターミナル
        kdePackages.dolphin        # ファイルマネージャー
        kdePackages.ark            # アーカイブマネージャー
        kdePackages.spectacle      # スクリーンショット
      ]))
    ];
  };
}
