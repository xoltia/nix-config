{ pkgs, ... }:

with pkgs; buildGoModule {
  pname = "botsu";
  version = "6b4c945";
  src = fetchFromGitHub {
    owner = "xoltia";
    repo = "botsu-oshi-stats";
    rev = "e8fb17f240221f0cd61d1a734ad5f00a8f2f3c5f";
    hash = "sha256-xNgJhS1JcUiM9pP4Tw5Fke07YCXUr0tR9hecWM3Zr6I=";
  };
  subPackages = [ "cmd/indexer" "cmd/server" "cmd/updater" ];
  vendorHash = "sha256-3qZ51QI4imOUpvGAczSfTNzq9Y/Bo8ogyJqiyaovNOg=";
}
