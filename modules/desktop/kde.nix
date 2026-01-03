{ pkgs, ... }:
{
  services.xserver.enable = true;

  # SDDM ディスプレイマネージャー
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # KDE Plasma 6 デスクトップ
  services.desktopManager.plasma6.enable = true;

  # KDE用パッケージ
  environment.systemPackages = with pkgs; [
    kdePackages.kate           # テキストエディタ
    kdePackages.konsole        # ターミナル
    kdePackages.dolphin        # ファイルマネージャー
    kdePackages.ark            # アーカイブマネージャー
    kdePackages.spectacle      # スクリーンショット
  ];
}
