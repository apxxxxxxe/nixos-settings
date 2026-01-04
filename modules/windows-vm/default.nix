# Windows VM Module
# NixOS module for declarative Windows 11 VM management using dockur/windows
{ config, pkgs, lib, ... }:

let
  # VM configuration
  vmConfig = {
    name = "windows";
    version = "win11";
    ram = "4G";
    cpuCores = "4";
    diskSize = "64G";
    dataDir = "/var/lib/windows-vm";
  };

  # OEM files for automatic setup during Windows installation
  oemFiles = pkgs.runCommand "windows-oem" {} ''
    mkdir -p $out
    cp ${./oem/install.bat} $out/install.bat
    cp ${./oem/setup.ps1} $out/setup.ps1
    cp ${./oem/winget-config.yaml} $out/winget-config.yaml
  '';

in {
  # Required packages
  environment.systemPackages = with pkgs; [
    freerdp3
  ];

  # Podman configuration
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers = {
      backend = "podman";

      containers.${vmConfig.name} = {
        image = "docker.io/dockurr/windows:latest";
        user = "root:root";
        autoStart = false;  # Manual start: sudo systemctl start podman-windows.service

        environment = {
          VERSION = vmConfig.version;
          RAM_SIZE = vmConfig.ram;
          CPU_CORES = vmConfig.cpuCores;
          DISK_SIZE = vmConfig.diskSize;
          # Japanese language and keyboard
          LANGUAGE = "Japanese";
          REGION = "ja-JP";
          # User credentials
          USERNAME = "user";
          PASSWORD = "password";
        };

        ports = [
          "127.0.0.1:8006:8006"       # Web VNC access
          "127.0.0.1:3389:3389/tcp"   # RDP
          "127.0.0.1:3389:3389/udp"   # RDP
        ];

        volumes = [
          "${vmConfig.dataDir}:/storage"
          "${oemFiles}:/oem:ro"
        ];

        extraOptions = [
          "--device=/dev/kvm"
          "--device=/dev/net/tun"
          "--cap-add=NET_ADMIN"
          "--stop-timeout=120"
        ];
      };
    };
  };

  # Create data directory
  systemd.tmpfiles.rules = [
    "d ${vmConfig.dataDir} 0755 root root -"
  ];

  # Shell aliases for convenience
  programs.zsh.shellAliases = {
    win-start = "sudo systemctl start podman-windows.service";
    win-stop = "sudo systemctl stop podman-windows.service";
    win-status = "sudo systemctl status podman-windows.service";
    win-rdp = "xfreerdp /v:127.0.0.1:3389 /u:user /dynamic-resolution /sound /microphone";
    win-web = "xdg-open http://127.0.0.1:8006";
    win-reset = "sudo systemctl stop podman-windows.service; sudo rm -f ${vmConfig.dataDir}/data.img ${vmConfig.dataDir}/windows.* && echo 'VM deleted. Run win-start to reinstall.'";
  };
}
