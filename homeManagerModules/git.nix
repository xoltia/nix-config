{ ... }:

{
  programs.git = {
    enable = true;
    userName  = "Juan Llamas";
    userEmail = "38849891+xoltia@users.noreply.github.com";
    extraConfig.init.defaultBranch = "main";
  };
}
