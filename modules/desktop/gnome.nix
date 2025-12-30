{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;

  # Gnome用パッケージ
  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];
}
