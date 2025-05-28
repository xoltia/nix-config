{ ... }:

{  
  programs.helix = {
    enable = true;
    settings = {
      editor = {
        line-number = "relative";
        bufferline = "multiple";
        color-modes = true;
      };
    };
  };
  home.sessionVariables.EDITOR = "hx";
}
