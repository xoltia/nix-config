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

      zstyle ':completion:*' menu select
      zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}
      zmodload -i zsh/complist
      bindkey -M menuselect '^[[Z' reverse-menu-complete

      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey '^X^E' edit-command-line
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = false;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = false;
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
