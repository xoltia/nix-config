{ inputs, pkgs, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  programs.zen-browser = {
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
        "zen.welcome-screen.seen" = true;
        "zen.view.show-newtab-button-top" = false;
        "zen.theme.accent-color" = "#3584e4";
        "zen.view.experimental-no-window-controls" = true;
        "extensions.autoDisableScopes" = 0;
        "signon.showAutoCompleteFooter" = false;
        "signon.rememberSignons" = false;
        "general.autoScroll" = true;
        "browser.translations.neverTranslateLanguages" = "ja";
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };

  defaultApplications.browser = "zen-twilight.desktop";
}
