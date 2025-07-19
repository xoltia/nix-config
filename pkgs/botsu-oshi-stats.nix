{ pkgs, ... }:

with pkgs; buildGoModule {
  pname = "botsu";
  version = "1caaa11";
  src = fetchFromGitHub {
    owner = "xoltia";
    repo = "botsu-oshi-stats";
    rev = "1caaa11d2197fe21c6b14ef974de471cc14eceb0";
    hash = "sha256-5fhum/nmqggjrVGg/jbvA9QGzsun2k0cX0hB80+b1vM=";
  };
  subPackages = [ "cmd/indexer" "cmd/server" "cmd/updater" ];
  vendorHash = "sha256-3qZ51QI4imOUpvGAczSfTNzq9Y/Bo8ogyJqiyaovNOg=";
}
