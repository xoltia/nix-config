{ pkgs, ... }:

with pkgs; buildGoModule {
  pname = "botsu";
  version = "0.3.5-dev.6e8b247";
  src = fetchFromGitHub {
    owner = "xoltia";
    repo = "botsu";
    rev = "6e8b2476bb0a47c930fa45d0062e1967e23dbadf";
    hash = "sha256-21qMoWRxrekbYv2VzJgDaTlM3xL9ygPmxlP2VJggDsc=";
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
