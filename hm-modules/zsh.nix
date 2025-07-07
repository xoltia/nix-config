{ lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases = {
      lg = "ll --git --git-ignore";
    };
    initContent  = ''
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
    '';
  };

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = lib.concatStrings [       
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$git_state"
        "$jobs"
        "$character"
      ];
      add_newline = false;
      directory = {
        truncation_length = 3;
        truncation_symbol = ".../";
        truncate_to_repo = false;
      };
      character = rec {
        success_symbol = "[%](bold 250)";
        error_symbol = success_symbol;
      };
    };
  };
}
