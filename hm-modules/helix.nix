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
   
    languages = {
      language-server.tailwindcss-ls = {
        command = "tailwindcss-language-server";
        args = [ "--stdio" ];
        config.userLanguages = { templ = "html"; };
      };

      language = [
        {
          name = "templ";
          language-servers = [ "tailwindcss-ls" "templ" ];
        }
      ];
    };
  };

  home.sessionVariables.EDITOR = "hx";
}
