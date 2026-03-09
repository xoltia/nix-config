{ lib, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Juan Llamas";
      user.email = "38849891+xoltia@users.noreply.github.com";
      init.defaultBranch = "main";
    };
  };

  programs.delta = {
    enable = true;
    options.syntax-theme = "ansi";
    enableGitIntegration = true;
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
