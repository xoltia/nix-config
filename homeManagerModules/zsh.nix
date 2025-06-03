{ ... }:

{
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable= true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
    };
    history.size = 10000;
    initContent  = ''
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      BACKGROUND_JOBS="%(1j. %F{red}[%j]%f.)"
      PS1="%K{blue}%n@%m%k %B%F{cyan}%~%f$BACKGROUND_JOBS%b %F{250}%%%f "
    '';
  };
}
