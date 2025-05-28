{ ... }:

{  
  programs.helix = {
    enable = true;
    settings = {
      editor = {
        line-number = "relative";
        bufferline = "multiple";
        color-modes = true;
        soft-wrap.enable = true;
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "error";
        };
      };
    };
  };
  home.sessionVariables.EDITOR = "hx";
}
