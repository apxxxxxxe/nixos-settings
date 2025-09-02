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
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.neovim = pkgs.neovim.overrideAttrs (old: {
        pname = "neovim-master";
        version = "master-${neovim-src.shortRev or "unknown"}";
        src = neovim-src;
        
        # ビルド時にgitが必要な場合
        nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.git ];
      });
      
      packages.${system}.default = self.packages.${system}.neovim;
    };
}
