{ lib, ... }:
{
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = lib.concatStrings [       
        "$directory"
        "$git_status"
        "$jobs"
        "$character"
      ];
      right_format = "$time";
      add_newline = false;
      directory = {
        truncation_length = 4;
        truncation_symbol = ".../";
        truncate_to_repo = false;
      };
      jobs = {
        format = "([\\[$symbol$number\\]]($style) )";
        symbol = "+";
        number_threshold = 1;
      };
      character = rec {
        success_symbol = "[%](bold 250)";
        error_symbol = success_symbol;
      };
      time = {
        disabled = false;
        style = "bold bright-black";
        format = "[$time]($style)";
      };
    };
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable= true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    initContent  = ''
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      # BACKGROUND_JOBS="%(1j. %F{red}[%j]%f.)"
      # PS1="%K{blue}%n@%m%k %B%F{cyan}%~%f$BACKGROUND_JOBS%b %F{250}%%%f "
    '';
  };
}
