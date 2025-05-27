{ pkgs, ... }: 

{
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc ];
  };

  environment.sessionVariables = {
    MOZC_IBUS_CANDIDATE_WINDOW = "ibus";
  };
}
