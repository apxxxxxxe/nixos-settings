# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

let
  user1 = "applepie";
  # デスクトップ選択: "wm", "gnome", "kde" のいずれか
  desktopType = "kde";
in
  { config, lib, pkgs, ... }:
  {
    disabledModules = [ "services/networking/xrdp.nix" ];

    imports =
      [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ./modules/rnnoise.nix
        ./pkgs/xrdp.nix
      ] ++ (
        if desktopType == "gnome" then [ ./modules/desktop/gnome.nix ]
        else if desktopType == "kde" then [ ./modules/desktop/kde.nix ]
        else [ ./modules/desktop/wm.nix ]
      );

    # Bootloader: 新規インストール時は初期値を元ファイルからコピーすること
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # iptables modules for Podman networking
    boot.kernelModules = [ "ip_tables" "iptable_nat" ];

    # Tell Xorg to use the nvidia driver (also valid for Wayland)
    # services.xserver.videoDrivers = ["nvidia"];

    # xbox controller
    hardware.xpadneo.enable = true;

    # Surface kernel: use stable instead of longterm
    hardware.microsoft-surface.kernelVersion = "stable";

    # Enable networking
    networking = {
        networkmanager.enable = true;
        hostName = "nixos"; # Define your hostname.
    #   # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
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
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-skk
        fcitx5-mozc
        fcitx5-gtk
      ];
    };

    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-extra
        noto-fonts-emoji
        hackgen-nf-font
      ];
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
    hardware.graphics.enable32Bit = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
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
    programs.dconf.enable = true;

    # バイナリのダイナミックリンクをnix storeに向けてくれる
    programs.nix-ld.enable = true;

    # gdk-pixbuf画像ローダーの有効化（StatusNotifier用SVGアイコン対応）
    programs.gdk-pixbuf = {
      modulePackages = with pkgs; [
        librsvg      # SVG画像フォーマット対応
      ];
    };

    programs.firefox = {
      enable = true;
      languagePacks = ["ja"];
    };


    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      xdg-user-dirs

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
      mise
      gcc
      gpp
      nodejs_24

      xrdp

      # essential
      go
      deno
      google-drive-ocamlfuse
      rustup
      neovim
      wezterm
      lazygit
      ghq
      fzf
      ripgrep

      pulseaudio # for pactl
      easyeffects

      # cursor theme
      (pkgs.callPackage ./pkgs/breeze-cursor-theme.nix {})
      kdePackages.breeze-icons
			papirus-icon-theme

      spotify
      spotify-tray

      neomutt
      isync

      tree

      # VPN
      wireguard-tools

      # WinApps
      podman-compose
    ];

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."${user1}" = {
      isNormalUser = true;
      description = user1;
      extraGroups = [ "networkmanager" "wheel" "video" "kvm" ]; # video: for backlight control via udev rules, kvm: for WinApps
      shell = pkgs.zsh;
      packages = with pkgs; [
        # painting
        azpainter
				aseprite

        # hobby
        discord
        spotifyd

        anki

				remmina

        # ukagaka
        wine # support 32-bit only
        # playonlinux
      ];
    };
    programs.steam.enable = true;

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
    services.cron = {
      enable = true;
      # systemCronJobs = [
      #   "*/5 * * * *      root    date >> /tmp/cron.log"
      # ];
    };

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
    system.stateVersion = "25.11"; # Did you read the comment?

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
    };

    # settings on virtualbox
    # guest
    # virtualisation.virtualbox.guest.enable = true;

    # Podman for WinApps
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      extraPackages = [ pkgs.crun ];  # rootless KVM に必須
    };

    networking.firewall.enable = true;
    networking.firewall.allowPing = true;
  }
