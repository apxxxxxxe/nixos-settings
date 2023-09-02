# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Tell Xorg to use the nvidia driver (also valid for Wayland)
  services.xserver.videoDrivers = ["nvidia"];

  # xbox controller
  hardware.xpadneo.enable = true;

  # Enable networking
  networking = {
    networkmanager.enable = true;
    hostName = "nixos"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-extra
      noto-fonts-emoji
      hackgen-nf-font
    ];
  };

  # Enable i3 window manager.
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
    windowManager.awesome.enable = true;
    displayManager.defaultSession = "none+awesome";

    # Configure keymap in X11
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
  services.blueman.enable = true;

  # for playonlinux and else
  hardware.opengl.driSupport32Bit = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = false;
    support32Bit = true;
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    git-filter-repo
    gh
    curl
    gnumake
    unzip
    unar
    jq

    blueman

    # essential
    go
    deno
    google-chrome
    cargo
    rustc
    neovim
    wezterm
    lazygit
    fzf
    ripgrep

    # cursor theme
    (import ./pkgs/breeze-cursor-theme.nix)

    # for i3
    feh
    dunst

    # for awesome
    bc
    acpi
    rofi
    pavucontrol
    pamixer

    spotify
    spotify-tray
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.applepie = {
    isNormalUser = true;
    description = "applepie";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      # painting
      azpainter

      # hobby
      discord
      spotifyd
      spotify-tui

      # ukagaka
      wine # support 32-bit only
      playonlinux
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  # settings on virtualbox
  virtualisation.virtualbox.guest.enable = true;
}
