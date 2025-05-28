{ inputs, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  programs.zen-browser = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisableAppUpdate = true;
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = { default_area = "menupanel"; };
        "sponsorBlocker@ajay.app" = { default_area = "menupanel"; };
        "446900e4-71c2-419f-a6a7-df9c091e268b" = { default_area = "menupanel"; };
      };
    };

    profiles.luisl = {
      isDefault = true;
      extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [
        ublock-origin
        sponsorblock
        bitwarden
      ];
      settings = {
        "zen.welcome-screen.seen" = true;
        "zen.view.show-newtab-button-top" = false;
        "zen.theme.accent-color" = "#a0d490";
        "extensions.autoDisableScopes" = 0;
        "signon.showAutoCompleteFooter" = false;
        "signon.rememberSignons" = false;
        "general.autoScroll" = true;
      };
    };
  };

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "zen-twilight.desktop";
    "x-scheme-handler/https" = "zen-twilight.desktop";
    "x-scheme-handler/chrome" = "zen-twilight.desktop";
    "text/html" = "zen-twilight.desktop";
    "application/x-extension-htm" = "zen-twilight.desktop";
    "application/x-extension-html" = "zen-twilight.desktop";
    "application/x-extension-shtml" = "zen-twilight.desktop";
    "application/xhtml+xml" = "zen-twilight.desktop";
    "application/x-extension-xhtml" = "zen-twilight.desktop";
    "application/x-extension-xht" = "zen-twilight.desktop";
  };
}
