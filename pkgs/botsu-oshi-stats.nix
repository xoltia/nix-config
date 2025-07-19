{ pkgs, ... }:

with pkgs; buildGoModule {
  pname = "botsu";
  version = "f1d509d";
  src = fetchFromGitHub {
    owner = "xoltia";
    repo = "botsu-oshi-stats";
    rev = "f1d509dba5fb19356c2cfa8f273d083416a023d1";
    hash = "sha256-BeoqWdn2xvCALDU2sUj/tnGOEipixeMMcHTNGawObAE=";
  };
  subPackages = [ "cmd/indexer" "cmd/server" "cmd/updater" ];
  vendorHash = "sha256-3qZ51QI4imOUpvGAczSfTNzq9Y/Bo8ogyJqiyaovNOg=";
}
