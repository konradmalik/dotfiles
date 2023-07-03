{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 2000;

      aws.disabled = true;
      battery.disabled = true;
      cmd_duration.disabled = true;
      crystal.disabled = true;
      dart.disabled = true;
      docker_context.disabled = true;
      dotnet.disabled = false;
      elixir.disabled = true;
      elm.disabled = true;
      env_var.disabled = true;
      erlang.disabled = true;
      gcloud.disabled = true;
      golang.disabled = false;
      hostname.disabled = false;
      java.disabled = false;
      jobs.disabled = false;
      julia.disabled = true;
      kubernetes.disabled = false;
      line_break.disabled = false;
      lua.disabled = false;
      memory_usage.disabled = true;
      nim.disabled = true;
      nix_shell.disabled = false;
      ocaml.disabled = true;
      openstack.disabled = true;
      package.disabled = true;
      perl.disabled = true;
      php.disabled = true;
      purescript.disabled = true;
      python.disabled = false;
      ruby.disabled = true;
      rust.disabled = false;
      shell = {
        disabled = false;
        zsh_indicator = "";
        bash_indicator = "bsh ";
        format = "[$indicator]($style)";
      };
      shlvl = {
        disabled = false;
        # start with 1
        # tmux adds another 1
        # 3 and more is suspicious
        threshold = 3;
      };
      singularity.disabled = true;
      swift.disabled = true;
      terraform.disabled = false;
      username.disabled = false;
      zig.disabled = true;
    };
  };

}
