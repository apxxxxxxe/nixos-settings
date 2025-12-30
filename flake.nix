{
  description = "My NixOS configuration";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # neovim-flake.url = "path:./flakes/neovim";
		neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
		let
		  overlays = [
        inputs.neovim-nightly-overlay.overlays.default
			];
		in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.applepie = import ./home.nix;
        }
        {
          #nixpkgs.overlays = [
          #  neovim-flake.outputs.overlay
          #];
          nixpkgs.overlays = overlays;
        }
      ];
    };
  };
}
