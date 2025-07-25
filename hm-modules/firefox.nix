{ inputs, pkgs, ... }:
{
  defaultApplications.browser = "firefox.desktop";
  programs.firefox = {
    enable = true;

    # See policy settings here.
    # https://mozilla.github.io/policy-templates/
    policies = {
      DisableTelemetry = true;
      DisableAppUpdate = true;
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          default_area = "menupanel";
          private_browsing = true;
        };
        "sponsorBlocker@ajay.app" = { default_area = "menupanel"; };
        "446900e4-71c2-419f-a6a7-df9c091e268b" = { default_area = "menupanel"; };
      };
      RequestedLocales = [ "en-US" "ja-JP" ];
      DNSOverHTTPS = {
        Enabled = true;
      };
    };

    profiles.luisl = {
      isDefault = true;
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        sponsorblock
        bitwarden
      ];
      # about:config options
      settings = {
        "browser.translations.neverTranslateLanguages" = "ja";
        "extensions.autoDisableScopes" = 0;
        "general.autoScroll" = true;
        "sidebar.main.tools" = "syncedtabs,history,bookmarks";
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "expand-on-hover";
        "signon.rememberSignons" = false;
        "signon.showAutoCompleteFooter" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "browser.uiCustomization.state" = ''
          {
            "placements": {
              "widget-overflow-fixed-list": [],
              "unified-extensions-area": [
                "sponsorblocker_ajay_app-browser-action",
                "ublock0_raymondhill_net-browser-action",
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
              ],
              "nav-bar": [
                "sidebar-button",
                "back-button",
                "forward-button",
                "stop-reload-button",
                "vertical-spacer",
                "customizableui-special-spring7",
                "urlbar-container",
                "customizableui-special-spring2",
                "downloads-button",
                "save-to-pocket-button",
                "unified-extensions-button",
                "firefox-view-button",
                "alltabs-button",
                "fxa-toolbar-menu-button",
                "reset-pbm-toolbar-button"
              ],
              "toolbar-menubar": [
                "menubar-items"
              ],
              "TabsToolbar": [],
              "vertical-tabs": [
                "tabbrowser-tabs"
              ],
              "PersonalToolbar": [
                "import-button",
                "personal-bookmarks",
                "fxms-bmb-button"
              ]
            }
          }
        '';
      };

      search = {
        force = true;
        order = [
          "google"
          "ddg"
          "nix-packages"
          "nix-options"
          "home-manager-options"
        ];
        engines =
          let
            nixosLogo = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          in
          {
            bing.metaData.hidden = true;
            amazondotcom-us.metaData.hidden = true;
            ebay.metaData.hidden = true;
            wikipedia.metaData.hidden = true;
            google.metaData.alias = "@g";

            youtube = {
              name = "YouTube";
              urls = [{
                template = "https://www.youtube.com/results";
                params = [
                  { name = "search_query"; value = "{searchTerms}"; }
                ];
              }];
              definedAliases = [ "@yt" "@youtube" ];
            };

            nix-packages = {
              name = "Nix Packages";
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = nixosLogo;
              definedAliases = [ "@nixpkgs" ];
            };

            home-manager-options = {
              name = "Home Manager Options";
              urls = [{
                template = "https://home-manager-options.extranix.com";
                params = [
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = nixosLogo;
              definedAliases = [ "@hmopts" ];
            };

            nix-options = {
              name = "Nix Options";
              urls = [{
                template = "https://search.nixos.org/options";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = nixosLogo;
              definedAliases = [ "@nixopts" ];
            };
          };
      };
    };
  };
}
