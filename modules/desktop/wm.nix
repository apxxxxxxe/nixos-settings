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
					qtile-extras
				];
			};
		};
  };
  services.displayManager.defaultSession = "none+awesome";
  services.xserver.displayManager.lightdm.enable = true;

	programs.nm-applet.enable = true;

  # タッチパッド設定
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      accelSpeed = "0.25";
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
  ];
}
