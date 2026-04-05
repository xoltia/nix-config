{ inputs, pkgs, lib, ... }:
{
  defaultApplications.browser = "firefox.desktop";
  home.file.".mozilla/firefox/luisl/chrome/firefox-gnome-theme".source = inputs.firefox-gnome-theme;
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
        "b6b8a44a-b6d7-42e2-ba01-636632196d01" = { default_area = "menupanel"; };
      };
      RequestedLocales = [ "en-US" "ja-JP" ];
      DNSOverHTTPS = {
        Enabled = true;
      };
    };
    profiles.luisl = {
      isDefault = true;
      userChrome = ''
        @import "firefox-gnome-theme/userChrome.css";
      '';
      userContent = ''
        @import "firefox-gnome-theme/userContent.css";
      '';
      extensions.packages =
      let
        addons = inputs.firefox-addons;
        addons-lib = addons.lib.${pkgs.stdenv.hostPlatform.system}; 
        addons-pkgs = addons.packages.${pkgs.stdenv.hostPlatform.system}; 
      in
      with addons-pkgs;
      [
        ublock-origin
        sponsorblock
        bitwarden
        # Custom extensions can be added using this command to generate:
        # nix run gitlab:rycee/nur-expressions#mozilla-addons-to-nix
        (addons-lib.buildFirefoxXpiAddon {
          pname = "youtube-row-fixer-extension";
          version = "1.1.7";
          addonId = "{b6b8a44a-b6d7-42e2-ba01-636632196d01}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4626654/youtube_row_fixer_extension-1.1.7.xpi";
          sha256 = "c1aa4f1a609837d9e60e858a89ca1a1c7da5c511a3aa615b0587344d98375ee5";
          meta = with lib;
          {
            homepage = "https://github.com/sapondanaisriwan/youtube-row-fixer";
            description = "A browser extension that lets you customize the number of videos, posts, and shelf items displayed per row on YouTube. It also fixes layout issues like oversized thumbnails and enhances your browsing experience.";
            license = licenses.mit;
            mozPermissions = [ "scripting" "storage" "https://www.youtube.com/*" ];
            platforms = platforms.all;
          };
        })
      ];
      # about:config options
      settings = {
        # Theme related settings
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.uidensity" = 0;
        "svg.context-properties.content.enabled" = true;
        "browser.theme.dark-private-windows" = false;
        "widget.gtk.rounded-bottom-corners.enabled" = true;

        # My settings
        "extensions.autoDisableScopes" = 0;
        "general.autoScroll" = true;
        "sidebar.main.tools" = "syncedtabs,history,bookmarks";
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = false;
        "sidebar.visibility" = "hide-sidebar";
        "signon.rememberSignons" = false;
        "signon.showAutoCompleteFooter" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "browser.translations.neverTranslateLanguages" = "ja";
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.uiCustomization.state" = ''
          {
            "placements": {
              "widget-overflow-fixed-list": [],
              "unified-extensions-area": [
                "sponsorblocker_ajay_app-browser-action",
                "ublock0_raymondhill_net-browser-action",
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action",
                "_b6b8a44a-b6d7-42e2-ba01-636632196d01_-browser-action"
              ],
              "nav-bar": [
                "back-button",
                "forward-button",
                "stop-reload-button",
                "vertical-spacer",
                "new-tab-button",
                "customizableui-special-spring7",
                "urlbar-container",
                "customizableui-special-spring2",
                "downloads-button",
                "unified-extensions-button",
                "reset-pbm-toolbar-button",
                "fxa-toolbar-menu-button"
              ],
              "toolbar-menubar": [
                "menubar-items"
              ],
              "TabsToolbar": [
                "tabbrowser-tabs",
                "alltabs-button"
              ],
              "vertical-tabs": [],
              "PersonalToolbar": [
                "personal-bookmarks",
                "fxms-bmb-button"
              ]
            },
            "seen": [
              "ublock0_raymondhill_net-browser-action",
              "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action",
              "sponsorblocker_ajay_app-browser-action",
              "developer-button",
              "screenshot-button",
              "_b6b8a44a-b6d7-42e2-ba01-636632196d01_-browser-action"
            ],
            "dirtyAreaCache": [
              "unified-extensions-area",
              "nav-bar",
              "toolbar-menubar",
              "TabsToolbar",
              "vertical-tabs",
              "PersonalToolbar"
            ],
            "currentVersion": 23,
            "newElementCount": 5
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
