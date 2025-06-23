{ pkgs, ... }:

with pkgs; buildGoModule {
  pname = "botsu";
  version = "0.3.4-dev.881c0d8";
  src = fetchFromGitHub {
    owner = "xoltia";
    repo = "botsu";
    rev = "881c0d8f825791f79c07cd8ecd98641c2c1b9c56";
    hash = "sha256-wiVW/TtZRkbRAcih7tOJTpNXat2HWctvyQFjSjdy2O0=";
  };
  subPackages = ["cmd/botsu"];
  vendorHash = "sha256-VZcR86ylVHI2jt4VdgvM8VA4iJtA6OM9ZhHF3tuG/vs=";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ yt-dlp ];

  postInstall = ''
    wrapProgram $out/bin/botsu \
      --prefix PATH : ${lib.makeBinPath [ yt-dlp ]}
  '';
}
