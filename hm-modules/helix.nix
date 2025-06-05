{ ... }:

{  
  programs.helix = {
    enable = true;
    settings = {
      theme = "fleet_dark";
      editor = {
        true-color = true;
        line-number = "relative";
        bufferline = "multiple";
        color-modes = true;
        soft-wrap.enable = true;
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "disable";
        };
      };
    };
  };
  home.sessionVariables.EDITOR = "hx";
}
