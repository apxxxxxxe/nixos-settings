{
  description = "My NixOS configuration";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-flake.url = "path:./flakes/neovim";
  };
  
  outputs = { self, nixpkgs, neovim-flake, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        {
          nixpkgs.overlays = [
            neovim-flake.outputs.overlay
          ];
        }
      ];
    };
  };
}
