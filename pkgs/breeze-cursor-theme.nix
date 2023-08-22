with import <nixpkgs> {}; # bring all of Nixpkgs into scope

stdenv.mkDerivation rec {
  name = "breezex-icon-theme";

  src = fetchzip {
    url = "https://github.com/ful1e5/BreezeX_Cursor/releases/download/v2.0.0/BreezeX-Light.tar.gz";
    sha256 = "sha256-72TXKX+q8gYwxGAZAFHfR5Q9xxlEj9a31GttevuLq8g=";
  };

  installPhase = ''
    mkdir -p $out/share/icons/BreezeX-Light
    cp -r $src/* $out/share/icons/BreezeX-Light/
  '';

  meta = with stdenv.lib; {
    description = "BreezeX Cursore theme";
  };
}
