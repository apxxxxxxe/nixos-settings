# Windows VM Module
# NixOS module for declarative Windows 11 VM management using dockur/windows
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.windowsVM;

  # OEM files for automatic setup during Windows installation
  oemFiles = pkgs.runCommand "windows-oem" {} ''
    mkdir -p $out
    cp ${./oem/install.bat} $out/install.bat
    cp ${./oem/setup.ps1} $out/setup.ps1
    cp ${./oem/winget-config.yaml} $out/winget-config.yaml
  '';

in {
  options.services.windowsVM = {
    enable = mkEnableOption "Windows 11 VM via Podman (dockur/windows)";

    name = mkOption {
      type = types.str;
      default = "windows";
      description = "Container name for the Windows VM";
    };

    ram = mkOption {
      type = types.str;
      default = "4G";
      description = "RAM size for the VM (e.g., 4G, 8G)";
    };

    cpuCores = mkOption {
      type = types.str;
      default = "4";
      description = "Number of CPU cores for the VM";
    };

    diskSize = mkOption {
      type = types.str;
      default = "64G";
      description = "Disk size for the VM (e.g., 64G, 128G)";
    };

    dataDir = mkOption {
      type = types.path;
      default = /var/lib/windows-vm;
      description = "Directory for VM persistent storage";
    };
  };

  config = mkIf cfg.enable {
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

        containers.${cfg.name} = {
          image = "docker.io/dockurr/windows:latest";
          user = "root:root";
          autoStart = false;  # Manual start: sudo systemctl start podman-windows.service

          environment = {
            VERSION = "win11";
            RAM_SIZE = cfg.ram;
            CPU_CORES = cfg.cpuCores;
            DISK_SIZE = cfg.diskSize;
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
            "${toString cfg.dataDir}:/storage"
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
      "d ${toString cfg.dataDir} 0755 root root -"
    ];

    # Shell aliases for convenience
    programs.zsh.shellAliases = {
      win-start = "sudo systemctl start podman-${cfg.name}.service";
      win-stop = "sudo systemctl stop podman-${cfg.name}.service";
      win-status = "sudo systemctl status podman-${cfg.name}.service";
      win-rdp = "xfreerdp /v:127.0.0.1:3389 /u:user /dynamic-resolution /sound /microphone";
      win-web = "xdg-open http://127.0.0.1:8006";
      win-reset = "sudo systemctl stop podman-${cfg.name}.service; sudo rm -f ${toString cfg.dataDir}/data.img ${toString cfg.dataDir}/windows.* && echo 'VM deleted. Run win-start to reinstall.'";
    };
  };
}
