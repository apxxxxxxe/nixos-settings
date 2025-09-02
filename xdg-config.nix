# /etc/nixos/xdg-config.nix
{ username ? "user" }:
{ config, pkgs, lib, ... }:

{
  environment.etc."xdg/user-dirs.defaults".text = ''
    DESKTOP=Desktop
    DOWNLOAD=Downloads
    TEMPLATES=Templates
    PUBLICSHARE=Public
    DOCUMENTS=Documents
    MUSIC=Music
    PICTURES=Pictures
    VIDEOS=Videos
  '';

  environment.etc."xdg/user-dirs.conf".text = ''
    enabled=False
  '';

  environment.sessionVariables = {
    XDG_DESKTOP_DIR = "$HOME/Desktop";
    XDG_DOCUMENTS_DIR = "$HOME/Documents";
    XDG_DOWNLOAD_DIR = "$HOME/Downloads";
    XDG_MUSIC_DIR = "$HOME/Music";
    XDG_PICTURES_DIR = "$HOME/Pictures";
    XDG_PUBLICSHARE_DIR = "$HOME/Public";
    XDG_TEMPLATES_DIR = "$HOME/Templates";
    XDG_VIDEOS_DIR = "$HOME/Videos";
  };

  systemd.tmpfiles.rules = [
    "d /home/${username}/Desktop 0755 ${username} ${username} -"
    "d /home/${username}/Documents 0755 ${username} ${username} -"
    "d /home/${username}/Downloads 0755 ${username} ${username} -"
    "d /home/${username}/Music 0755 ${username} ${username} -"
    "d /home/${username}/Pictures 0755 ${username} ${username} -"
    "d /home/${username}/Public 0755 ${username} ${username} -"
    "d /home/${username}/Templates 0755 ${username} ${username} -"
    "d /home/${username}/Videos 0755 ${username} ${username} -"
  ];

  system.activationScripts.removeJapaneseDirectories = ''
    user_home="/home/${username}"
    if [ -d "$user_home" ]; then
      rmdir "$user_home/デスクトップ" 2>/dev/null || true
      rmdir "$user_home/ドキュメント" 2>/dev/null || true
      rmdir "$user_home/ダウンロード" 2>/dev/null || true
      rmdir "$user_home/音楽" 2>/dev/null || true
      rmdir "$user_home/画像" 2>/dev/null || true
      rmdir "$user_home/公開" 2>/dev/null || true
      rmdir "$user_home/テンプレート" 2>/dev/null || true
      rmdir "$user_home/ビデオ" 2>/dev/null || true
    fi
  '';
}
