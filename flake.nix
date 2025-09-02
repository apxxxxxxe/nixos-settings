{
  description = "My NixOS configuration";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-flake.url = "path:./flakes/neovim";
    # 他の専用flakeも追加可能
  };
  
  outputs = { self, nixpkgs, neovim-flake, ... }: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        {
          nixpkgs.overlays = [
            neovim-flake.overlay
          ];
        }
      ];
    };
  };
}
