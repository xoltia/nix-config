{ pkgs, ... }:

with pkgs; buildGoModule {
  pname = "botsu";
  version = "f1d509d";
  src = fetchFromGitHub {
    owner = "xoltia";
    repo = "botsu-oshi-stats";
    rev = "f1d509dba5fb19356c2cfa8f273d083416a023d1";
    hash = "";
  };
  subPackages = [ "cmd/indexer" "cmd/server" "cmd/updater" ];
  vendorHash = "";
}
