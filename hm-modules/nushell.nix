{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;
    plugins = with pkgs.nushellPlugins; [
      polars
      formats
      gstat
      query
    ];
    extraConfig = /*nu*/ ''
      $env.PROMPT_COMMAND = {||
          let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
              null => $env.PWD
              "" => '~'
              $relative_pwd => ([~ $relative_pwd] | path join)
          }

          let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
          let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
          let path_segment = $"($path_color)($dir)(ansi reset)" | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"

          let git_info = do -i {
              let stats = gstat
              if ($stats.repo_name != "no_repository") {
                  let branch = $stats.branch
                  let cols = $stats | transpose
                  let dirty_idx = if (($cols | where ($it.column0 | str starts-with "idx_") | get column1 | math sum) > 0) { "+" } else { "" }
                  let dirty_wt = if (($cols | where ($it.column0 | str starts-with "wt_") | get column1 | math sum) > 0) { "*" } else { "" }
                  let ahead = if ($stats.ahead > 0) { "↑" } else { "" }
                  let behind = if ($stats.behind > 0) { "↓" } else { "" }
                  let stashes = if ($stats.stashes > 0) { "$" } else { "" }
                  let status = $"($dirty_idx)($dirty_wt)($stashes)($ahead)($behind)"
                  $" (ansi blue_bold)($branch)[($status)](ansi reset)"
              } else { "" }
          }

          $"($path_segment)($git_info)"
      }
    '';
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = false;
  };
}
