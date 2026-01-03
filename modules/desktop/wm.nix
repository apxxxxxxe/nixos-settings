{ pkgs, ... }:
{
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
  };
  services.displayManager.defaultSession = "none+awesome";
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
  services.xrdp.defaultWindowManager = "awesome";

  # ノートPCの蓋を閉じたときの動作
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";              # バッテリー駆動時: サスペンド
    HandleLidSwitchExternalPower = "suspend"; # 外部電源接続時: サスペンド
    HandleLidSwitchDocked = "ignore";         # ドッキングステーション接続時: 何もしない
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    variant = "";
    layout = "us";
    options = "grp:alt_space_toggle, ctrl:swapcaps";
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
}
