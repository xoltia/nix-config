{ pkgs, ... }:

with pkgs; stdenv.mkDerivation {
  name = "jido";

  src = fetchurl {
    url = "https://github.com/BrookJeynes/jido/releases/download/v1.2.0/x86_64-linux.tar.gz";
    sha256 = "5072582b734b455730c75d7e4666602f2ea5b1cc14fe4c5bb8a119f07775e283";
  };

  unpackPhase = "tar xvf $src --strip-components=1";

  installPhase = ''
    mkdir -p $out/bin
    cp jido $out/bin/
    chmod +x $out/bin/jido
  '';
}
