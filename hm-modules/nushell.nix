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
                  if (($status | str length) > 0) {
                    $" (ansi blue_bold)($branch)[($status)](ansi reset)"
                  } else {
                    $" (ansi blue_bold)($branch)(ansi reset)"                    
                  }
              } else { "" }
          }

          $"($path_segment)($git_info)"
      }

      $env.PROMPT_COMMAND_RIGHT = {||
        let time_segment = ([
            (ansi reset)
            (ansi magenta)
            (date now | format date '%H:%M:%S')
        ] | str join | str replace --regex --all "([/:])" $"(ansi green)''${1}(ansi magenta)")

        let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
            (ansi rb)
            ($env.LAST_EXIT_CODE)
            (char space)
          ] | str join)
        } else { "" }

        let cmd_duration = $env.CMD_DURATION_MS | into duration --unit ms
        let duration_segment = if ($cmd_duration > 3sec) {([
            (ansi yb)
            (if ($cmd_duration < 1min) {
              $cmd_duration | format duration sec
            } else if ($cmd_duration < 1hr) {
              $cmd_duration | format duration min
            } else {
              $cmd_duration | format duration hr
            })
            (char space)
        ] | str join)} else { "" }
        ([$last_exit_code, $duration_segment, $time_segment] | str join)
      }
    '';
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = false;
  };
}
