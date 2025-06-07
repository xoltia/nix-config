{ lib, ... }:

{
  programs.git = {
    enable = true;
    userName  = "Juan Llamas";
    userEmail = "38849891+xoltia@users.noreply.github.com";
    extraConfig.init.defaultBranch = "main";
    delta.enable = true;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git.paging = {
        colorArg = "always";
        useConfig = false;
        pager = lib.concatStringsSep " " [
          "delta"
          "--dark"
          "--paging=never"
          "--line-numbers"
          "--hyperlinks"
          "--hyperlinks-file-link-format='lazygit-edit://{path}:{line}'"
        ];
      };
    };
  };
}
