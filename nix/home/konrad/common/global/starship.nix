{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 2000;

      shell = {
        disabled = false;
        zsh_indicator = "";
        bash_indicator = "bsh ";
        format = "[$indicator]($style)";
      };

      aws.disabled = true;
      battery.disabled = true;
      cmd_duration. disabled = true;
      crystal.disabled = true;
      dart.disabled = true;
      docker_context. disabled = true;
      dotnet.disabled = true;
      elixir.disabled = true;
      elm.disabled = true;
      env_var.disabled = true;
      erlang.disabled = true;
      gcloud.disabled = true;
      golang.disabled = false;
      line_break.disabled = false;
      java.disabled = false;
      julia.disabled = true;
      kubernetes.disabled = false;
      lua.disabled = false;
      memory_usage.disabled = true;
      nim.disabled = true;
      nix_shell.disabled = false;
      package.disabled = true;
      ocaml.disabled = true;
      openstack.disabled = true;
      perl.disabled = true;
      php.disabled = true;
      purescript.disabled = true;
      python.disabled = false;
      ruby.disabled = true;
      rust.disabled = false;
      shlvl.disabled = true;
      singularity.disabled = true;
      swift.disabled = true;
      zig.disabled = true;
    };
  };

}
