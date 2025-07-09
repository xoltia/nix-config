{ pkgs, ... }:

with pkgs; buildGoModule {
  pname = "botsu";
  version = "0.3.4";
  src = fetchFromGitHub {
    owner = "xoltia";
    repo = "botsu";
    rev = "v0.3.4";
    hash = "sha256-3kqHFMwB/5w8ucynxoMXMOiQjHkTUdbi/C18zd40hII=";
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
