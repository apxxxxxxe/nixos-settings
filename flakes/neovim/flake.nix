{
  description = "Latest Neovim from master";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-src = {
      url = "github:neovim/neovim";
      flake = false;
    };
  };
  
  outputs = { self, nixpkgs, neovim-src }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
    in {
      packages = forAllSystems (system: 
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          neovim = pkgs.neovim.overrideAttrs (old: {
            pname = "neovim-master";
            version = "master-${neovim-src.shortRev or "unknown"}";
            src = neovim-src;
            nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.git ];
          });
        });
      
      # overlayを提供
      overlay = final: prev: {
        neovim = self.packages.${final.system}.neovim;
      };
    };
}
