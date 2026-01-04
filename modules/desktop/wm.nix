# Tiling Window Manager Desktop Module
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.desktopWM;

  # DPI からスケール値を計算
  # 96 dpi = 1x, 192 dpi = 2x
  scaleFactor = cfg.dpi / 96.0;
  cursorSize = builtins.floor (24 * scaleFactor);

in {
  options.services.desktopWM = {
    enable = mkEnableOption "Tiling WM desktop environment (i3, awesome, qtile)";

    defaultWM = mkOption {
      type = types.enum [ "awesome" "i3" "qtile" ];
      default = "awesome";
      description = "Default window manager for login session and XRDP";
    };

    dpi = mkOption {
      type = types.int;
      default = 96;
      description = "Display DPI for Xft and cursor scaling (96 = standard, 192 = 2x HiDPI)";
    };
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      windowManager = {
        i3.enable = true;
        awesome.enable = true;
        qtile = {
          enable = true;
          extraPackages = python3Packages: with python3Packages; [
            pyxdg          # StatusNotifierのアイコン検索に必須
            qtile-extras
          ];
        };
      };

      # DPI 設定: Xresources を sessionCommands で設定
      displayManager.sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
        Xft.dpi: ${toString cfg.dpi}
        Xft.autohint: 0
        Xft.lcdfilter: lcddefault
        Xft.hintstyle: hintfull
        Xft.hinting: 1
        Xft.antialias: 1
        Xft.rgba: rgb
        Xcursor.size: ${toString cursorSize}
        EOF
      '';

      # Configure keymap in X11
      xkb = {
        variant = "";
        layout = "us";
        options = "grp:alt_space_toggle, ctrl:swapcaps";
      };
    };

    # セッション名: i3/awesome は "none+xxx"、qtile は "qtile"
    services.displayManager.defaultSession =
      if cfg.defaultWM == "qtile" then "qtile"
      else "none+${cfg.defaultWM}";
    services.xserver.displayManager.lightdm.enable = true;

    programs.nm-applet.enable = true;
    # backlight control
    programs.light.enable = true;

    # タッチパッド設定
    services.libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        accelSpeed = "0.5";
        tappingDragLock = true;
      };
    };

    # XRDP設定
    services.xrdp.enable = true;
    services.xrdp.openFirewall = true;
    services.xrdp.defaultWindowManager = cfg.defaultWM;

    # ノートPCの蓋を閉じたときの動作
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";              # バッテリー駆動時: サスペンド
      HandleLidSwitchExternalPower = "suspend"; # 外部電源接続時: サスペンド
      HandleLidSwitchDocked = "ignore";         # ドッキングステーション接続時: 何もしない
    };

    # HiDPI: 環境変数
    environment.sessionVariables = {
      # GTK スケーリング
      GDK_SCALE = toString (if scaleFactor >= 1.5 then 2 else 1);
      GDK_DPI_SCALE = toString (if scaleFactor >= 1.5 then 0.5 else 1);
      # Qt スケーリング
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_SCALE_FACTOR = toString scaleFactor;
    };

    # WM用パッケージ
    environment.systemPackages = with pkgs; [
      # for i3
      feh
      dunst
      # for awesome
      bc
      acpi
      rofi
      pavucontrol
      pamixer

      networkmanagerapplet
    ];

    # Picom コンポジター
    services.picom = {
      enable = true;
      backend = "glx";
      vSync = true;

      # 影の設定
      shadow = true;
      shadowOpacity = 0.5;
      shadowOffsets = [ (-7) (-7) ];
      shadowExclude = [
        "name = 'Notification'"
        "class_g = 'Conky'"
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];

      # タスクバー（dock）のみ透明化
      opacityRules = [
        "85:window_type = 'dock'"
      ];

      settings = {
        # 全ウィンドウに角丸（12px）
        corner-radius = 12;

        # タスクバー（dock）のみブラー
        blur-method = "dual_kawase";
        blur-size = 10;
        blur-background-exclude = [
          "window_type != 'dock'"
        ];
      };
    };

    # Home Manager: カーソルと GTK 設定（dpi 連動）
    home-manager.users.applepie = {
      home.pointerCursor = {
        name = "BreezeX-Light";
        package = pkgs.callPackage ../../pkgs/breeze-cursor-theme.nix {};
        size = cursorSize;
        gtk.enable = true;
        x11.enable = true;
      };

      gtk = {
        enable = true;
        gtk2.force = true;  # KDE がシンボリックリンクを実ファイルに変換する問題を回避
        gtk3.extraConfig = {
          gtk-cursor-theme-size = cursorSize;
        };
      };
    };
  };
}
